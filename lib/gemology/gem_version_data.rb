require 'stringio'
module Gemology
  class GemVersionData
    include ::Gemology::Logable

    def initialize( gemfile )
      @data          = StringIO.open( IO.read( gemfile ), "r" )
      @file_hashes   = nil
      @format        = with_data{ |data| ::Gem::Format.from_io( data ) }
      @specification = @format.spec 

      @gem_sha1      = with_data{ |data| ::Digest::SHA1.hexdigest( data.string ) }
      logger.info "#{@specification.full_name} SHA1 : #{@gem_sha1}"

      @gem_md5       = with_data{ |data| ::Digest::MD5.hexdigest( data.string  ) }
      logger.info "#{@specification.full_name} MD5  : #{@gem_md5}"
    end

    def calculate_file_hashes( format )
      logger.info "Calculating individual file digests"
      @file_hashes  = Hash.new{ |h,k| h[k] = Hash.new } # sha1/md5 sum of each file in the gem

      digests = { :sha1 => ::Digest::SHA1.new, :md5  => ::Digest::MD5.new }
      format.file_entries.each do |entry, file_data|
        digests.each_pair do |k, digest|
          digest.reset
          digest << file_data
          @file_hashes[entry][k] = digest.hexdigest
        end
      end
      return nil
    end

    def with_data( &block )
      @data.rewind
      yield @data
    end
  end
end
