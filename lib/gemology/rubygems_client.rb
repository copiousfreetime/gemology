module Gemology
  class RubygemsClient
    include Logable
    def self.default_uri
      "http://rubygems.org"
    end
    def self.default_cdn_uri
      "http://production.cf.rubygems.org/"
    end

    def self.for_cdn
      RubygemsClient.new( RubygemsClient.default_cdn_uri )
    end

    def initialize( base = "http://rubygems.org" )
      @base_uri  = URI.parse( base ).to_s
      @specs_uri = URI.join( @base_uri , "specs.4.8.gz" ).to_s
    end

    def specs_gz
      if @specs_gz then
        logger.info "Using cached version of #{@specs_uri}"
      else
        logger.info "Downloading #{@specs_uri}"
        response = get( @specs_uri )
        @specs_gz = response.body
      end
      return @specs_gz
    end

    def specs
      logger.info "Loading #{@specs_uri}"
      Marshal.load( Gem.gunzip( self.specs_gz ) )
    end

    def gemfile_uri( fname )
      URI.join( @base_uri, "gems/#{fname}" ).to_s
    end

    def gemfile( fname )
      get( gemfile_uri( fname ) ).body
    end

    def etag_of_gemfile( fname )
      raw = head( gemfile_uri( fname ))['etag']
      raw = raw.gsub(/"/,'') if raw
    end

    private

    def get( uri, limit = 10 )
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0

      response = Net::HTTP.get_response(URI.parse(uri))

      case response
        when Net::HTTPSuccess
          return response
        when Net::HTTPRedirection 
          return get(response['location'], limit - 1)
        else
          response.error!
      end
    end

    def head( uri, limit = 10 )
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0

      uri      = URI.parse( uri )
      http     = Net::HTTP.new( uri.host, uri.port )
      response = http.head( uri.path )

      case response
      when Net::HTTPSuccess
        return response
      when Net::HTTPRedirection 
        return head(response['location'], limit - 1)
      else
        msg = "#{response.code} retrieving #{uri}"
        logger.error( msg )
        raise msg
      end
    end 
  end
end
