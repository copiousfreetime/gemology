require 'pluginfactory'
require 'gemology/logable'
require 'gemology/cloud_container'

module Gemology
  class ResqueJob
    include PluginFactory
    include Logable

    def self.derivative_dirs
      %w[ "resque_jobs" ]
    end

    def self.job_names
      derivatives.keys.reject { |c| c.to_s =~ /::/ }
    end

    def rubygems_container
      CloudContainer.new.for('rubygems')
    end
  end
end

require 'gemology/resque_jobs/fetch_store'
require 'gemology/resque_jobs/extract_metadata'
require 'gemology/resque_jobs/check_fetched'

