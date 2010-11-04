module Gemology
  module Db
    class Requirement < ::Sequel::Model
      one_to_many :gem_version_requirements
      many_to_many :gem_versions, :join_table => :gem_version_requirements
    end
  end
end
