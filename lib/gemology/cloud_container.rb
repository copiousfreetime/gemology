require 'cloudfiles'
module Gemology
  class CloudContainer

    def self.defaults
      @defaults ||= eval( IO.read( File.expand_path( "~/.gemologyrc" ) ) )
    end

    def initialize( opts = {} )
      @username = opts['username'] || CloudContainer.defaults['username']
      @api_key  = opts['api_key']  || CloudContainer.defaults['api_key']
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
