module Gemology
  class CloudContainer
    include Configurability
    def self.config_key
      :cloud_container
    end

    def initialize( opts = {} )
      @username = opts['username'] || config.username
      @api_key  = opts['api_key']  || config.api_key
      @cf = ::CloudFiles::Connection.new( :username => @username,
                                          :api_key  => @api_key )
    end

    def for( container )
      @cf.container( container )
    end

    def rubygems
      @cf.container( 'rubygems' )
    end
  end
end
