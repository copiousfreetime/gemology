module Gemology
  module Db
    class Dependency < ::Sequel::Model
      one_to_many  :gem_version_dependency
      many_to_many :gem_versions, :join_table => :gem_version_dependencies
      plugin :isolated_find_or_create
    end
  end
end
