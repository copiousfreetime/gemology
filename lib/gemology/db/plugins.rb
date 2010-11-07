module Sequel
  module Plugins
    module IsolatedFindOrCreate
      module ClassMethods
        def isolated_find_or_create( *args, &block )
          found = nil
          dataset.lock("ACCESS EXCLUSIVE") do |ds|
            found = dataset[*args] || create(*args, &block)
          end
          return found
        end
      end
    end
  end
end
