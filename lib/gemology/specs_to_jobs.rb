require 'net/http'
require 'gemology/resque_job'

module Gemology
  class SpecsToJobs
    include Logable

    def self.specs_uri
      @specs_uri ||= "http://rubygems.org/specs.4.8.gz"
    end

    def specs_uri
      SpecsToJobs.specs_uri
    end
    
    def destinations
      ::Gemology::ResqueJob.job_names
    end

    def valid_destination?( dest )
      destinations.include?( dest )
    end

    def submit_to( dest )

    end

    def specs_gz
      if @specs_gz then
        logger.info "Using cached version of #{specs_uri}"
      else
        logger.info "Downloading #{SpecsToJobs.specs_uri}"
        response = fetch( SpecsToJobs.specs_uri )
        @specs_gz = response.body
      end
      return @specs_gz
    end

    def specs
      logger.info "Loading #{SpecsToJobs.specs_uri}"
      Marshal.load( Gem.gunzip( specs_gz ) )
    end

    def submit_to( job )
      s = self.specs
      logger.info "Submitting #{s.size} #{job} jobs"
      count = 0
      s.each do |a|
        spec = ::Gemology::SpecLite.new( *a )
        #Resqeue.enqueue( ResqueJob.get_classname( job ), spec.file_name )
        count += 1
      end
      logger.info "Finished submitting #{count} #{job} jobs"
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

