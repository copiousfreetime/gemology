module Gemology
  module Db
    class Author< ::Sequel::Model
      one_to_many :gem_version_authors
      many_to_many :gem_versions, :join_table => :gem_version_authors
      plugin :isolated_find_or_create
    end
  end
end
