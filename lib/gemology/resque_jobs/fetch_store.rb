require 'gemology/spec_lite'
require 'gemology/resque_job'
require 'gemology/cloud_container'
require 'cloudfiles'
require 'digest/md5'

module Gemology
  module ResqueueJobs
    class FetchStore < ResqueJob

      def self.queue
      "fetch_store"
      end

      def self.perform( gemfile )
        job = FetchStoreJob.new( gemfile )
        job.run
      end

      def initialize( gemfile )
        @client = RubygemsClient.new
        @gemfile = gemfile
        logger.info "Starting fetch and store of #{@gemfile}"
      end

      def run
        fname = File.basename( @gemfile )

        logger.info "Fetching #{@gemfile}"
        contents = @client.gemfile( gemfile ) 

        logger.info "Storing #{fname}"
        obj = rubygems_container.create_object( fname )

        if obj.write( contents ) then
          logger.info "Finished fetch and store of #{@uri}"
        else
          logger.error "Woops, had a problem, not sure what with #{@uri}"
        end
      rescue => e
        logger.error e
        e.backtrace.each { |b| logger.debug b }
        raise e
      end
    end
  end
end
