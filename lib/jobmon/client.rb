require 'retryable'
require 'jobmon/errors'

module Jobmon
  class Client
    def conn
      @conn ||= Faraday.new(url: Jobmon.configuration.endpoint) do |faraday|
        faraday.request  :url_encoded
        faraday.request  :json
        faraday.response :json
        faraday.adapter  Faraday.default_adapter
      end
    end

    def api_key
      Jobmon.configuration.monitor_api_key
    end

    def job_monitor(name, estimate_time, &block)
      logging("before job_start #{name}")
      job_id = job_start(name, estimate_time)
      logging("after job_start #{name}")
      result = block.call(job_id)
      logging("before job_end #{name}")
      job_end(name, job_id)
      logging("after job_end #{name}")
      result
    # NOTE: Rake.application.runから投げられる例外は全てSystemExitとなるため
    rescue SystemExit, StandardError => e
      logging("Failed job #{name}", level: :warn)
      logging("before job_end #{name}")
      job_end(name, job_id, failed: true)
      logging("after job_end #{name}")
      raise e
    end

    def job_start(name, estimate_time)
      Retryable.retryable(tries: 3) do
        body = {
          job: {
            name: name,
            end_time: Time.current.since(estimate_time),
            start_at: Time.current,
            rails_env: Rails.env,
            hostname: Jobmon.configuration.hostname,
          }
        }
        response = conn.post "/api/apps/#{api_key}/jobs.json", body
        response.body['id']
      end
    rescue => e
      logging("Failed to send job_start #{name}", level: :warn)
      Jobmon.configuration.error_handle.call(Jobmon::RequestError.new(e))
      nil
    end

    def job_end(name, job_id, failed: false)
      return unless job_id
      body = {
        job: {
          rails_env: Rails.env,
          end_at: Time.current,
          status: failed ? 'failed' : nil
        }.compact
      }
      Retryable.retryable(tries: 3) do
        conn.put "/api/apps/#{api_key}/jobs/#{job_id}/finished.json", body
      end
    rescue => e
      logging("Failed to send job_end #{name}", level: :warn)
      Jobmon.configuration.error_handle.call(Jobmon::RequestError.new(e))
      nil
    end

    def send_queue_log(count)
      body = {
        queue_log: {
          count: count,
          rails_env: Rails.env,
        }
      }
      response = conn.post "/api/apps/#{api_key}/queue_logs.json", body
      response.body['id']
    rescue => e
      logging("Failed to send send_queue_log", level: :warn)
      Jobmon.configuration.error_handle.call(Jobmon::RequestError.new(e))
      nil
    end

    private

    def logging(text, level: :info)
      log_text = "[Jobmon] #{text}"
      logger&.public_send(level, log_text)
    end

    def logger
      Jobmon.configuration.logger
    end
  end
end
