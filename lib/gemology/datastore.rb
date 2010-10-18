require 'amalgalite'
require 'gemology/gem_version_data'

module Gemology
  class Datastore
    def self.open( db_path, &block )
     ds =  Gemology::Datastore.new( db_path )
     if block_given?
       begin
         yield ds
       ensure
         ds.close
       end
     else
       return ds
     end
    end

    def initialize( db_path )
      @db = ::Amalgalite::Database.new( db_path, "w+" )
    end

    def close
      @db.close
    end

    def add_gem_version_data( gem_version_data )

    end
  end
end
