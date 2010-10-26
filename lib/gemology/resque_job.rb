require 'pluginfactory'
require 'resque'
require 'gemology/logable'
require 'gemology/cloud_container'

module Gemology
  class ResqueJob
    include PluginFactory
    include Logable

    def self.derivative_dirs
      %w[ "resque_jobs" ]
    end

    def self.gem_base_urj
      "http://rubygems.org/gems"
    end

    def self.job_names
      derivatives.keys.reject { |c| c.to_s =~ /::/ }
    end

    def self.valid_job_name?( job_name )
      job_names.include?( job_name )
    end

    def rubygems_container
      CloudContainer.new.for('rubygems')
    end
  end
end

require 'gemology/resque_jobs/fetch_store'
require 'gemology/resque_jobs/extract_metadata'
require 'gemology/resque_jobs/check_fetched'

