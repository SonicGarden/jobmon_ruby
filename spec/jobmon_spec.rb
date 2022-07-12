require "spec_helper"

describe Jobmon do
  it "has a version number" do
    expect(Jobmon::VERSION).not_to be nil
  end

  describe '.available?', no_jobmon_mock: true do
    it 'falsey if Rails.env.test?' do
      allow(Rails).to receive(:env).and_return('test')

      expect(Jobmon.configuration.release_stage).to eq 'test'
      expect(Jobmon.configuration.available_release_stages).to eq %w[staging production]
      expect(Jobmon.available?).to be_falsey
    end

    it 'truthy if Rails.env.production?' do
      allow(Rails).to receive(:env).and_return('production')

      expect(Jobmon.configuration.release_stage).to eq 'production'
      expect(Jobmon.configuration.available_release_stages).to eq %w[staging production]
      expect(Jobmon.available?).to be_truthy
    end

    it "falsey if release_stage == 'production-2'" do
      Jobmon.configuration.release_stage = 'production-2'

      expect(Jobmon.configuration.release_stage).to eq 'production-2'
      expect(Jobmon.configuration.available_release_stages).to eq %w[staging production]
      expect(Jobmon.available?).to be_falsey
    end

    it "truthy if release_stage == 'production-2' and available_release_stages contains 'production-2'" do
      Jobmon.configuration.release_stage = 'production-2'
      Jobmon.configuration.available_release_stages = %w[production-2]

      expect(Jobmon.configuration.release_stage).to eq 'production-2'
      expect(Jobmon.configuration.available_release_stages).to eq %w[production-2]
      expect(Jobmon.available?).to be_truthy
    end
  end
end
