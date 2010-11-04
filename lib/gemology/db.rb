module Gemology
  module Db    
    include Configurability
    def self.config_key
      :datastore
    end

    def self.configure( config )
      @config = config
    end

    def self.config
      @config
    end

    def self.init
      if not defined? @connection then
        @connection = ::Sequel.connect( self.config.to_hash )
        load_models
      end
    end

    def self.load_models
      Gemology.libdir('db') do
        require 'author'
        require 'dependency'
        require 'emails'
        require 'license'
        require 'requirement'
        require 'gem'
        require 'gem_version'
        require 'gem_version_author'
        require 'gem_version_dependency'
        require 'gem_version_email'
        require 'gem_version_file'
        require 'gem_version_license'
        require 'gem_version_raw_specification'
        require 'gem_version_requirements'
      end
    end
  end
end
