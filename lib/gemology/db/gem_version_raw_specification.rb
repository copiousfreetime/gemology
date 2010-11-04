module Gemology
  module Db
    class GemVersionRawSpecification < ::Sequel::Model
      many_to_one :gem_version
    end
  end
end
