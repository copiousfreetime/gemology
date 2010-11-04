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
    end
  end
end
