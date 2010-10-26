require 'gemology/spec_lite'
require 'gemology/resque_job'
require 'gemology/cloud_container'
require 'httparty'
require 'cloudfiles'
require 'digest/md5'

module Gemology
  module ResqueueJobs
    class FetchStore < ResqueJob

      def self.queue
      "fetch_store"
      end

      def self.perform( url )
        job = FetchStoreJob.new( url )
        job.run
      end


      def initialize( url )
        @url = url 
        logger.info "Starting fetch and store of #{@url}"
      end

      def run
        fname = File.basename( URI.parse( @url ).path )

        logger.info "Fetching #{@url}"
        resp = HTTParty.get( @url )

        logger.info "Storing #{fname}"
        obj = rubygems_container.create_object( fname )

        if obj.write( resp.body ) then
          logger.info "Finished fetch and store of #{@url}"
        else
          logger.error "Woops, had a problem, not sure what with #{@url}"
        end
      rescue => e
        logger.error e
        e.backtrace.each { |b| logger.debug b }
        raise e
      end
    end
  end
end
