module Jobmon
  class Client
    def host
      'https://job-mon.sg-apps.com'
    end

    def conn
      @conn ||= Faraday.new(url: host) do |faraday|
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
      job_id = job_start(name, estimate_time)
      begin
        yield(job_id)
      ensure
        job_end(job_id)
      end
    end

    def job_start(name, estimate_time)
      body = {
        job: {
          name: name,
          end_time: Time.current.since(estimate_time),
          rails_env: Rails.env,
        }
      }
      response = conn.post "/api/apps/#{api_key}/jobs.json", body
      response.body['id']
    rescue => e
      Jobmon.configuration.error_handle.call(e)
      nil
    end

    def job_end(job_id)
      return unless job_id
      body = {
        job: {
          rails_env: Rails.env,
        }
      }
      response = conn.put "/api/apps/#{api_key}/jobs/#{job_id}/finished.json", body
      response.body['id']
    rescue => e
      Jobmon.configuration.error_handle.call(e)
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
      Jobmon.configuration.error_handle.call(e)
      nil
    end
  end
end
