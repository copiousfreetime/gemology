module Gemology
  module Db
    class GemVersionAuthor < ::Sequel::Model
      many_to_one :author
      many_to_one :gem_version
    end
  end
end
