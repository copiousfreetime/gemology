module Gemology
  module Db
    class License < ::Sequel::Model
      many_to_many :gem_version, :join_table => :gem_version_licenses
    end
  end
end
