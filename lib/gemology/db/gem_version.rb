module Gemology
  module Db
    class GemVersion < ::Sequel::Model
      many_to_one :gem
      one_to_one  :gem_version_raw_specification
      one_to_many :gem_version_licenses
      one_to_many :gem_version_authors
      one_to_many :gem_version_emails
      one_to_many :gem_version_files
      one_to_many :gem_version_dependencies

      many_to_many :authors,      :join_table => :gem_version_authors
      many_to_many :emails,       :join_table => :gem_version_emails
      many_to_many :requirements, :join_table => :gem_version_requirements
      many_to_many :dependencies, :join_table => :gem_version_dependencies
      many_to_many :licenses    , :join_table => :gem_version_licenses

      def self.from_gem_version_data( gem, gvd )
        gv = Db::GemVersion[ :full_name => gvd.full_name ]
        raise Gemology::Error, "GemVersion #{gvd.full_name} is already in the database" if gv
        gv = Db::GemVersion.new do |gv|
          gv.full_name                      = gvd.full_name
          gv.md5                            = gvd.md5
          gv.sha1                           = gvd.sha1
          gv.version                        = gvd.version.to_s
          gv.platform                       = gvd.platform.to_s
          gv.is_prerelease                  = gvd.prerelease?
          gv.release_date                   = gvd.date
          gv.required_rubygems_version      = gvd.required_rubygems_version.to_s
          gv.required_ruby_version          = gvd.required_ruby_version.to_s
          gv.packaged_rubygems_version      = gvd.packaged_rubygems_version
          gv.packaged_specification_version = gvd.packaged_specification_version
          gv.summary                        = gvd.summary
          gv.homepage                       = gvd.homepage
          gv.rubyforge_project              = gvd.rubyforge_project
          gv.description                    = gvd.description
          gv.autorequire                    = gvd.autorequire
          gv.has_signing_key                = gvd.signing_key != nil
          gv.has_cert_chain                 = gvd.cert_chain != nil
          gv.has_extension                  = !gvd.extensions.empty?
          gv.post_install_message           = gvd.post_install_message
        end
        gem.add_gem_version( gv )

        gv.add_ordered_authors( gvd.authors )
        gv.add_ordered_emails( gvd.emails )
        gv.add_requirements( gvd.requirements )
        gv.add_dependencies( gvd.dependencies )
        gv.add_meta_licenses( gvd.meta_licenses )
        gv.add_file_licenses( gvd.file_licenses )
        gv.gem_version_raw_specification = GemVersionRawSpecification.new( :ruby => gvd.specification.to_ruby )
        gv.add_file_info( gvd.file_info )

        return gv
      end

      def add_meta_licenses( meta )
        meta.each do |l|
          add_license( :name => l, :content => l, :sha1 => Digest::SHA1.hexdigest( l ) )
        end
      end

      def add_file_licenses( list )
        list.each do |lic|
          add_license( lic )
        end
      end

      def add_file_info( file_info_list )
        file_info_list.each do |file_info|
          add_gem_version_file( Db::GemVersionFile.new( file_info.to_hash ) )
        end
      end

      def add_dependencies( deps )
        deps.each do |dep|
          h = { :gem_name        => dep.name,
                :is_prerelease   => dep.prerelease?,
                :dependency_type => dep.type.to_s }
          # Not sure if this is ever more than one, but it has the potential to
          # be, so coding for that
          dep.requirement.requirements.each do |r|
            f = h.merge( :operator => r.first, :version => r.last.to_s )
            d = Db::Dependency.find_or_create( f )
            add_dependency( d )
          end
        end
      end

      def add_ordered_authors( authors )
        authors.each_with_index do |author, idx|
          a = Db::Author.find_or_create( :name => author )
          add_gem_version_author( :author => a, :listed_order => idx )
        end
      end

      def add_ordered_emails( emails )
        emails.each_with_index do |email, idx|
          e = Db::Email.find_or_create( :email => email )
          add_gem_version_email( :email => e, :listed_order => idx )
        end
      end

      def add_requirements( requirements )
        requirements.each do |req|
          r = Db::Requirement.find_or_create( :requirement => req )
          add_requirement( r )
        end
      end
    end
  end
end
