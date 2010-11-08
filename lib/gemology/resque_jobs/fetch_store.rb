module Gemology
  module ResqueJobs
    class FetchStore < ResqueJob

      def self.queue
      "fetch_store"
      end

      def self.perform( gemfile )
        job = FetchStore.new( gemfile )
        job.run
      end

      def initialize( gemfile )
        @client = RubygemsClient.new
        @gemfile = gemfile
        logger.info "Starting fetch and store of #{@gemfile}"
      end

      def queue_for_extraction( gemfile )
        logger.info "#{gemfile} queued for ExtractMetadata"
        ::Resque.enqueue( ResqueJob.get_subclass( "extractmetadata" ), gemfile )
      end

      def run
        fname = File.basename( @gemfile )

        logger.info "Fetching #{@gemfile}"
        contents = @client.gemfile( @gemfile ) 

        logger.info "Storing #{fname}"
        obj = rubygems_container.create_object( fname )

        if obj.write( contents ) then
          logger.info "Finished fetch and store of #{@gemfile}"
          queue_for_extraction( @gemfile )
        else
          logger.error "Woops, had a problem, not sure what with #{@gemfile}"
        end
      rescue => e
        log_and_reraise( e )
      end
    end
  end
end
