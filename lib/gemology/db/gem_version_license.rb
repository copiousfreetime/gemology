module Gemology
  module Db
    class GemVersionLicense < ::Sequel::Model
      one_to_many :meta_licenses, :class => ::Gemology::Db::License
      one_to_many :file_licenses, :class => ::Gemology::Db::License
      one_to_many :gem_versions
    end
  end
end
