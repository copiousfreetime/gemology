module Gemology
  module Db
    class GemVersionRequirement < ::Sequel::Model
      many_to_one :requirement
      many_to_one :gem_version
    end
  end
end
