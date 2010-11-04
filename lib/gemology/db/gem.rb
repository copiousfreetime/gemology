module Gemology
  module Db
    class Gem < ::Sequel::Model
      one_to_many :gem_versions
    end
  end
end
