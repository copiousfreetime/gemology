
module Gemology
  class ResqueJob
    include PluginFactory
    include Logable
    include Configurability

    def self.config_key
      :resque
    end

    def self.configure( config )
      @config = config
    end

    def self.config
      @config
    end


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


