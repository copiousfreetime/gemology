module Gemology
  module Db
    class GemVersionExistsError < ::Gemology::Error; end
    class GemVersionEncodingError < ::Gemology::Error; end
    class GemVersion < ::Sequel::Model
      include ::Gemology::Logable
      many_to_one :gem
      one_to_one  :gem_version_raw_specification
      one_to_many :gem_version_files

      one_to_many :gem_version_authors
      one_to_many :gem_version_emails
      one_to_many :gem_version_requirements
      one_to_many :gem_version_dependencies
      one_to_many :gem_version_licenses

      many_to_many :authors,      :join_table => :gem_version_authors
      many_to_many :emails,       :join_table => :gem_version_emails
      many_to_many :requirements, :join_table => :gem_version_requirements
      many_to_many :dependencies, :join_table => :gem_version_dependencies
      many_to_many :licenses    , :join_table => :gem_version_licenses

      def self.from_gem_version_data( gem, gvd )
        gv = Db::GemVersion[ :full_name => gvd.full_name ]
        raise Gemology::Db::GemVersionExistsError, "GemVersion #{gvd.full_name} is already in the database" if gv
        gv = Db::GemVersion.new do |gv|
          gv.full_name                      = gvd.full_name
          gv.md5                            = gvd.md5
          gv.sha1                           = gvd.sha1
          gv.size                           = gvd.size
          gv.version                        = gv.convert_to_utf8( gvd.version.to_s )
          gv.platform                       = gvd.platform.to_s
          gv.is_prerelease                  = gvd.prerelease?
          gv.release_date                   = gvd.date
          gv.required_rubygems_version      = gvd.required_rubygems_version.to_s
          gv.required_ruby_version          = gvd.required_ruby_version.to_s
          gv.packaged_rubygems_version      = gv.convert_to_utf8( gvd.packaged_rubygems_version ) # yeah odd, I know
          gv.packaged_specification_version = gvd.packaged_specification_version
          gv.summary                        = gv.convert_to_utf8( gvd.summary )
          gv.homepage                       = gvd.homepage
          gv.rubyforge_project              = gvd.rubyforge_project
          gv.description                    = gv.convert_to_utf8( gvd.description )
          gv.autorequire                    = gvd.autorequire
          gv.has_signing_key                = gvd.signing_key != nil
          gv.has_cert_chain                 = gvd.cert_chain != nil
          gv.has_extension                  = !gvd.extensions.empty?
          gv.post_install_message           = gv.convert_to_utf8( gvd.post_install_message )
        end
        gem.add_gem_version( gv )

        gv.add_ordered_authors( gvd.authors )
        gv.add_ordered_emails( gvd.emails )
        gv.add_requirements( gvd.requirements )
        gv.add_dependencies( gvd.dependencies )
        gv.add_licenses( gvd.meta_licenses )
        gv.add_licenses( gvd.file_licenses )
        gv.gem_version_raw_specification = GemVersionRawSpecification.new( :specification => gvd.specification.to_yaml )
        gv.add_file_info( gvd.file_info )

        return gv
      end

      def add_licenses( list )
        list.each do |member|
          if String === member then
            member.strip!
            next unless member.length > 0
            member = { :name => member, :content => member, :sha1 => Digest::SHA1.hexdigest( member ) }
          end
          lic = Db::License.isolated_find_or_create( :sha1 => member[:sha1] ) do |rec|
            rec.name = member[:name]
            rec.content = convert_to_utf8(member[:content])
          end
          add_license( lic )
        end
      end

      #
      # poor mans utf8 conversion needed for the database
      # us-ascci is a subset of utf8, so those we can skip if that is what they
      # are and it is a valid encoding
      #
      # If it is not valid encoding, then try each encoding (except for
      # ASCII-8BIT) until one says it is a valid encoding, then force and
      # Iconv conversion from that encoding to UTF-8
      #
      def convert_to_utf8( str )
        return str if str.nil?
        str = str.to_s # you would thing that everything passed in would be a string -- riskman gem
        return str if %w[ UTF-8 US-ASCII ].include?( str.encoding.name ) && str.valid_encoding?
        before_bytes = str.bytesize
        if (str.encoding.name != "ASCII-8BIT") && str.valid_encoding? then
          from = str.encoding.name
        else
          from = find_encoding_of( str )
          from = "UTF-8" if from == "ASCII-8BIT"
        end

        # special case if it looks like it is US-ASCII to UTF-8 just force it,
        # it is valid
        if from == "US-ASCII" then
          str.force_encoding( "UTF-8" )
          return str
        end

        result = nil
        used = nil
        %w[ UTF-8//TRANSLIT//IGNORE UTF-8//IGNORE ].each do |to|
          logger.info "Force an encoding conversion of #{before_bytes} #{str.encoding.name} bytes from #{from} to #{to}"
          begin
            result = Iconv.conv( to, from, str )
            used = to
            break
          rescue => e
            logger.error e.inspect
          end
        end
        raise GemVersionEncodingError, "Unable to do utf8 conversion on string >>>#{str}<<<" unless result

        result.force_encoding( "UTF-8" )
        logger.info "Forced an encoding conversion of #{before_bytes} #{str.encoding.name} bytes from #{from} to #{result.bytesize} bytes at #{used}"
        return result
      end

      def find_encoding_of( str, skip = %w[ UTF-8 ASCII-8BIT ] )
        test_str = str.dup
        encoding_list.each do |enc|
          next if skip.include?( enc.name )
          test_str.force_encoding( enc ) 
          return enc.name if test_str.valid_encoding?
        end
        return "ASCII-8BIT"
      end

      # ad hoc reording of testing encodings, haphazardly discovered based upon
      # what seemed appropriate based on the conversions in rubygems
      def encoding_list
        head = []
        tail = []
        Encoding.list.each do |enc|
          if enc.name =~ /\A(Big5|SJIS|CP|GB)/ then
            tail << enc
          else
            head << enc
          end
        end
        return [head, tail].flatten
      end

      def add_file_info( file_info_list )
        file_info_list.each do |file_info|
          file_info[:filename] = convert_to_utf8( file_info[:filename] )
          add_gem_version_file( Db::GemVersionFile.new( file_info.to_hash ) )
        end
      end

      def add_dependencies( deps )
        deps.each do |dep|
          h = { :gem_name        => dep.name.to_s,  # some are symbols
                :is_prerelease   => dep.prerelease?,
                :dependency_type => (dep.type || :runtime ).to_s }
          # Not sure if this is ever more than one, but it has the potential to
          # be, so coding for that
          dep.requirement.requirements.each do |r|
            f = h.merge( :operator => r.first, :version => r.last.to_s )
            d = Db::Dependency.isolated_find_or_create( f )
            add_dependency( d )
          end
        end
      end

      def add_ordered_authors( authors )
        authors.each_with_index do |author, idx|
          next unless author.length > 0
          author = convert_to_utf8( author )
          a = Db::Author.isolated_find_or_create( :name => author )
          add_gem_version_author( :author => a, :listed_order => idx )
        end
      end

      def add_ordered_emails( emails )
        emails.each_with_index do |email, idx|
          next unless email.length > 0
          email = convert_to_utf8( email )
          e = Db::Email.isolated_find_or_create( :email => email )
          add_gem_version_email( :email => e, :listed_order => idx )
        end
      end

      def add_requirements( requirements )
        requirements.each do |req|
          req = convert_to_utf8( req )
          r = Db::Requirement.isolated_find_or_create( :requirement => req )
          add_requirement( r )
        end
      end
    end
  end
end
