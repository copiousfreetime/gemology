module Gemology
  module Db
    class License < ::Sequel::Model
      many_to_many :gem_version, :join_table => :gem_version_licenses
      plugin :isolated_find_or_create
    end
  end
end
