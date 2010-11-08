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
          logger.warn "<#{e.class} #{e.message}> means #{@gemfile} does not exist in our cloud container"
        rescue ::Gemology::Db::GemVersionExistsError => e
          logger.warn "<#{e.class} #{e.message}> means #{@gemfile} has already been extracted.  To re-extract first try 'gemology-remove-gem-version #{@gemfile}'"
        rescue ::Gemology::Db::GemVersionEncodingError => e
          logger.warn "<#{e.class} #{e.message}> means #{@gemfile} has some string encoding issues that could not be resolved."
        rescue ::Gem::Package::FormatError => e
          logger.warn "<#{e.class} #{e.message}> means #{@gemfile} cannot opened by Ruby #{RUBY_VERSION} with Rubygems #{Gem::VERSION}"
        rescue ::ArgumentError => e
          # unfortunately, this is the only way to skip this error
          if e.backtrace[0] =~ /normalize_yaml_input/ then
          #if e.message == "invalid byte sequence in UTF-8" then
            logger.warn "<#{e.class} #{e.message}> means #{@gemfile} cannot opened by Ruby #{RUBY_VERSION} with Rubygems #{Gem::VERSION}"
          else
            log_and_reraise( e )
          end
        rescue => e
          log_and_reraise( e )
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
