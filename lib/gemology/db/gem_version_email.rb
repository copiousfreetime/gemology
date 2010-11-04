module Gemology
  module Db
    class GemVersionEmail < ::Sequel::Model
      many_to_one :email
      many_to_one :gem_version
    end
  end
end
