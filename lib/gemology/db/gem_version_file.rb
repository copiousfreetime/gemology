module Gemology
  module Db
    class GemVersionFile < ::Sequel::Model
      many_to_one :gem_version
    end
  end
end
