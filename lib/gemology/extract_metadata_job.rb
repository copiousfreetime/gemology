require 'gemology/logable' 
require 'gemology/spec_lite'
require 'cloudfiles'
require 'digest/md5'
require 'digest/sha1'
require 'rubygems/format'
require 'fileutils'

module Gemology
  #
  # This is is a Resque job
  #
  class ExtractMetadataJob 
    include ::Gemology::Logable

    def self.queue
      "extract_metadata"
    end

    def self.container
      unless @container then
        cf = ::CloudFiles::Connection.new( :username => "copiousfreetime", :api_key => "cbf15dfbf487d9b00706ed18940dca8e" )
        @container = cf.container( 'rubygems' )
      end
      return @container
    end

    def self.perform( gemfile )
      job = ExtractMetadataJob.new( gemfile )
      job.run
    end

    def initialize( gemfile )
      @gemfile = gemfile
      @workdir = work_dir_for( gemfile )

      @gemfile_md5  = nil # md5 of the .gem file itself
      @gemfile_sha1 = nil # sha1 of the .gem fiel itself

      @file_hashes   = Hash.new{ |h,k| h[k] = Hash.new } # sha1/md5 sum of each file in the gem
      @specification = nil

      logger.info "Starting extraction of metadata from #{@gemfile}"
    end

    def container
      ExtractMetadataJob.container
    end

    def work_dir_for( gemfile )
      basename = File.basename( gemfile, ".gem" )
      work_dir = ::Gemology::Paths.work_path( basename )
      FileUtils.mkdir_p work_dir
      return work_dir 
    end

    # Save the gemfile to a local file and calculate the md5sum and sha1
    # at the same time since we will be processing each byte for writing
    # to the disk.
    #
    # Return a Gem::Format object
    def save_to_local_file_and_calculate_digests( gemfile ) 
      local_name = File.join( @workdir , gemfile )
      logger.info "Fetching #{gemfile} from cloud container to #{local_name}"

      sha1 = ::Digest::SHA1.new
      md5  = ::Digest::MD5.new

      File.open( local_name, "w+") do |f|
        obj = container.object( gemfile )
        obj.data_stream do |chunk|
          sha1 << chunk
          md5  << chunk
          f.write( chunk )
        end
      end

      @gemfile_md5  = md5.hexdigest
      @gemfile_sha1 = sha1.hexdigest

      return local_name
    end

    def calculate_file_hashes( format )
      logger.info "Calculating individual file digests"

      digests = { :sha1 => ::Digest::SHA1.new,
        :md5  => ::Digest::MD5.new }

        format.file_entries.each do |entry, file_data|
          digests.each_pair do |k, digest|
            digest.reset
            digest << file_data
            @file_hashes[entry][k] = digest.hexdigest
          end
        end
        return nil
    end

    def run
      begin
        local_name     = save_to_local_file_and_calculate_digests( @gemfile )
        format         = ::Gem::Format.from_file_by_path( local_name )
        calculate_file_hashes( format )
        @specification = format.spec
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
