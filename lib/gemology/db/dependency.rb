module Gemology
  module Db
    class Dependency < ::Sequel::Model
      one_to_many  :gem_version_dependency
      many_to_many :gem_versions, :join_table => :gem_version_dependencies
    end
  end
end
