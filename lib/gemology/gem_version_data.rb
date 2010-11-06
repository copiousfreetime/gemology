module Gemology
  class GemVersionData
    include ::Gemology::Logable

    attr_reader :md5
    attr_reader :sha1
    attr_reader :specification

    def initialize( gemfile )
      @gemfile       = gemfile
      @data          = StringIO.open( IO.read( gemfile ), "r" )
      @file_hashes   = nil
      @format        = with_data{ |data| ::Gem::Format.from_io( data ) }
      @specification = @format.spec 
      @sha1          = with_data{ |data| ::Digest::SHA1.hexdigest( data.string ) }
      @md5           = with_data{ |data| ::Digest::MD5.hexdigest( data.string  ) }

      calculate_file_hashes( @format )
    end

    # The name of the gem
    def gem_name
      @specification.name
    end

    def full_name
      @specification.full_name
    end

    def version
      @specification.version
    end

    def date
      @specification.date
    end

    def prerelease?
      @specification.version.prerelease?
    end

    def platform
      @specification.platform
    end

    def required_rubygems_version
      @specification.required_rubygems_version
    end

    def required_ruby_version
      @specification.required_ruby_version
    end

    def packaged_rubygems_version
      @specification.rubygems_version
    end

    def packaged_specification_version
      @specification.specification_version
    end

    def summary
      @specification.summary
    end

    def description
      @specification.description
    end

    def homepage
      @specification.homepage
    end

    def dependencies
      @specification.dependencies
    end

    def requirements
      @specification.requirements
    end

    def authors
      @specification.authors
    end

    def emails
      [@specification.email].flatten
    end

    def rubyforge_project
      @specification.rubyforge_project
    end

    def autorequire
      @specification.autorequire
    end

    def signing_key
      @specification.signing_key
    end

    def cert_chain
      @specification.cert_chain
    end

    def post_install_message
      @specification.post_install_message
    end

    def calculate_file_hashes( format )
      logger.info "Calculating individual file digests"
      @file_hashes  = Hash.new{ |h,k| h[k] = Hash.new } # sha1/md5 sum of each file in the gem

      digests = { :sha1 => ::Digest::SHA1.new, :md5  => ::Digest::MD5.new }
      format.file_entries.each do |entry, file_data|
        digests.each_pair do |kind, digest|
          digest.reset
          digest << file_data
          @file_hashes[entry][kind] = digest.hexdigest
        end
      end
      return nil
    end

    def store_to_db( db )
      g = Db::Gem.find_or_create( :name => gem_name )
      g.add_version_data( self )
    end

    def with_data( &block )
      @data.rewind
      yield @data
    end
  end
end
