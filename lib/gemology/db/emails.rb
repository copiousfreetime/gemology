module Gemology
  module Db
    class Email < ::Sequel::Model
      one_to_many :gem_version_emails
      many_to_many :gem_versions, :join_table => :gem_version_emails
      plugin :isolated_find_or_create
    end
  end
end
