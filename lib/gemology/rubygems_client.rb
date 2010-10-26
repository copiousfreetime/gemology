require 'net/http'
require 'gemology/logable'

module Gemology
  class RubygemsClient
    include Logable
    def initialize( base = "http://rubygems.org" )
      @base_uri  = URI.parse( base ).to_s
      @specs_uri = URI.join( @base_uri , "specs.4.8.gz" ).to_s
    end

    def specs_gz
      if @specs_gz then
        logger.info "Using cached version of #{@specs_uri}"
      else
        logger.info "Downloading #{@specs_uri}"
        response = fetch( @specs_uri )
        @specs_gz = response.body
      end
      return @specs_gz
    end

    def specs
      logger.info "Loading #{@specs_uri}"
      Marshal.load( Gem.gunzip( self.specs_gz ) )
    end

    def gemfile_uri( fname )
      URI.join( @base_uri, "gems", fname ).to_s
    end

    def gemfile( fname )
      fetch( gemfile_uri( fname ) ).body
    end

    private

    def fetch( uri, limit = 10 )
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0
      response = Net::HTTP.get_response(URI.parse(uri))
      case response
        when Net::HTTPSuccess
          return response
        when Net::HTTPRedirection 
          return fetch(response['location'], limit - 1)
        else
          response.error!
      end
    end

  end
end
