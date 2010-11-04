module Gemology
  module Db
    class GemVersionDependency < ::Sequel::Model
      many_to_one :gem_version
      many_to_one :dependency
    end
  end
end
