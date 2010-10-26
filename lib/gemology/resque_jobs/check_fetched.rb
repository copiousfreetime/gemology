require 'gemology/spec_lite'
require 'gemology/resque_job'
require 'gemology/cloud_container'
require 'gemology/rubygems_client'
require 'httparty'
require 'cloudfiles'
require 'digest/md5'

module Gemology
  module ResqueueJobs
    class CheckFetched < ResqueJob

      def self.queue
        "check_fetched"
      end

      def self.perform( gemfile )
        job = CheckFetched.new( gemfile )
        job.run
      end

      def initialize( gemfile )
        @gemfile = gemfile
        @client = RubygemsClient.for_cdn
      end

      def requeue( gemfile )
        logger.info "#{gemfile} queued for FetchStore"
        ::Resque.enqueue( ResqueJob.get_subclass( "fetchstore" ), gemfile )
      end

      def run
        fname = File.basename( @gemfile )
        md5 = @client.etag_of_gemfile( @gemfile )
        obj = rubygems_container.object( @gemfile )

        if md5 == obj.etag then
          logger.info "#{@gemfile} => OK"
        else
          logger.warn "#{@gemfile} (rubygems) #{md5} : #{obj.etag} (cloudfile) => MISMATCH"
          requeue( @gemfile )
        end
      rescue NoSuchObjectException => nsoe
        logger.warn "#{@gemfile} does not exist in cloudfiles container"
        requeue( @gemfile )
      rescue => e
        logger.error e
        e.backtrace.each { |b| logger.debug b }
        raise e
      end
    end
  end
end