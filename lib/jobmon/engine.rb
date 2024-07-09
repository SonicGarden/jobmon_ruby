module Jobmon
  class Engine < ::Rails::Engine
    initializer 'jobmon' do |app|
      ActiveSupport::Deprecation.warn("Please switch to the main branch to install jobmon. Example: `gem 'jobmon', github: 'SonicGarden/jobmon_ruby', branch: 'main`")
    end
  end
end
