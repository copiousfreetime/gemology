module Gemology
  module ResqueJobs
    class ExtractMetadata < ResqueJob

      def self.queue
      "extract_metadata"
      end

      def self.perform( gemfile )
        job = ExtractMetadata.new( gemfile )
        job.run
      end

      def initialize( gemfile )
        @gemfile = gemfile
        @workdir = nil # work_dir_for( gemfile )

      end

      def work_dir_for( gemfile )
        basename = File.basename( gemfile, ".gem" )
        work_dir = File.join( ResqueJob.config.work_dir, basename )
        work_dir += ".#{Process.pid}"
        FileUtils.mkdir_p work_dir
        return work_dir 
      end

      def fetch( gemfile )
        logger.info "Fetching #{gemfile} from cloud container"
        rubygems_container.object( gemfile )
      end

      def save_to_local_file( cloud_obj, gemfile ) 
        local_name = File.join( @workdir , gemfile )
        logger.info "Saving to #{local_name}"
        cloud_obj.save_to_filename( local_name )
        return local_name
      end

      def run
        begin
          logger.info "Starting extraction of metadata from #{@gemfile}"
          metadata = ::Gemology::GemVersionData.new( fetch( @gemfile ).data )
          ::Gemology::Db.open do |db|
            logger.info "Storing #{@gemfile} in database"
            metadata.store_to_db( db )
          end
        rescue ::NoSuchObjectException => e
          logger.error e.message
          logger.error "Not recording this as a failed job since we don't have the gem anyway"
        rescue => e
          logger.error e.message
          e.backtrace.each { |b| logger.debug b }
          raise e
        ensure
          if @workdir then
            logger.info "Cleaning up #{@workdir}"
            FileUtils.rm_rf @workdir
          end
          logger.info "Finished extraction of metadata from #{@gemfile}"
        end
      end
    end
  end
end
