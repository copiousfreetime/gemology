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
        @workdir = work_dir_for( gemfile )

        logger.info "Starting extraction of metadata from #{@gemfile}"
      end

      def work_dir_for( gemfile )
        basename = File.basename( gemfile, ".gem" )
        work_dir = ::Gemology::Paths.work_path( basename )
        work_dir += ".#{Process.pid}"
        FileUtils.mkdir_p work_dir
        return work_dir 
      end

      def save_to_local_file( gemfile ) 
        local_name = File.join( @workdir , gemfile )
        logger.info "Fetching #{gemfile} from cloud container to #{local_name}"
        rubygems_container.object( gemfile ).save_to_filename( local_name )
        return local_name
      end

      def run
        begin
          local_name = save_to_local_file( @gemfile )
          metadata   = ::Gemology::GemVersionData.new( local_name )
          ::Gemology::Datastore.open( ::Gemology::Paths.db_path( "gemology.db" ) ) do |ds|
            ds.add_gem_version_data( metadata )
          end
        rescue => e
          logger.error e
          e.backtrace.each { |b| logger.debug b }
          raise e
        ensure
          logger.info "Cleaning up #{@workdir}"
          FileUtils.rm_rf @workdir
        end
      end
    end
  end
end
