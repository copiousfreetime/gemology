module Gemology
  class GemVersionData
    include ::Gemology::Logable

    attr_reader :md5
    attr_reader :sha1
    attr_reader :specification
    attr_reader :file_info

    def initialize( gemfile )
      @gemfile       = gemfile
      @data          = StringIO.open( IO.read( gemfile ), "r" )
      @file_info     = []
      @file_licenses = []
      @format        = with_data{ |data| ::Gem::Format.from_io( data ) }
      @specification = @format.spec 
      @sha1          = with_data{ |data| ::Digest::SHA1.hexdigest( data.string ) }
      @md5           = with_data{ |data| ::Digest::MD5.hexdigest( data.string  ) }

      calculate_file_info( @format )
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

    def extensions
      @specification.extensions
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

    def test_files
      @specification.test_files
    end

    def extra_rdoc_files
      @specification.extra_rdoc_files
    end

    def extensions
      @specification.extensions
    end

    def meta_licenses
      @specification.licenses
    end

    def file_licenses
      @file_licenses
    end

    def executables
      @specification.executables.collect { |d| File.join(@specification.bindir, d ) }
    end

    def calculate_file_info( format )
      logger.info "Calculating individual file information"
      digest = ::Digest::SHA1.new

      format.file_entries.each do |entry, file_data|
        digest.reset
        entry_path = entry['path']
        file_data = "" if entry['size'] == 0 # file_data is nil for 0 byte files
        digest << file_data
        sha1 = digest.hexdigest

        fi = FileInfo.new( sha1, entry_path, entry['size'], entry['mode'] )
        fi.is_test_file       = test_files.include?( entry_path )
        fi.is_extra_rdoc_file = extra_rdoc_files.include?( entry_path )
        fi.is_extension_file  = extensions.include?( entry_path )
        fi.is_executable_file = executables.include?( entry_path )
        fi.is_license_file    = is_license_file?( entry_path )
        @file_info << fi

        if fi.is_license_file then
          @file_licenses << { :name => entry_path, :sha1 => sha1, :content => file_data }
        end
      end
      return nil
    end

    def is_license_file?( filename ) 
      return true if filename =~ /license/i 
      return true if filename =~ /copying/i
      return false
    end

    def store_to_db( db )
      g = Db::Gem.find_or_create( :name => gem_name )
      g.add_version_data( self )
    end

    def with_data( &block )
      @data.rewind
      yield @data
    end

    FileInfo = ::Struct.new( :sha1, :filename, :size, :mode, 
                              :is_test_file, :is_extra_rdoc_file, 
                              :is_extension_file, :is_executable_file, 
                              :is_license_file )
    class FileInfo
      def to_hash
        h = {}
        each_pair { |k,v| h[k.to_sym] = v }
        return h
      end
    end
  end
end
