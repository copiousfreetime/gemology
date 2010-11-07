module Gemology
  module Db
    class Gem < ::Sequel::Model
      one_to_many :gem_versions
      plugin :isolated_find_or_create

      # Add all the data from a GemVersionData to the database from this gem
      def add_version_data( gem_version_data )
        gv = GemVersion.from_gem_version_data( self, gem_version_data )
      end
    end
  end
end
