module Gemology
  class CloudFiles
    include Configurability
    include Logable

    def self.config_key
      :cloud_files
    end

    def self.configure( config )
      @config = config
    end

    def self.config
      @config
    end

    def initialize( opts = {} )
      @username = opts['username'] || ::Gemology::CloudFiles.config.username
      @api_key  = opts['api_key']  || ::Gemology::CloudFiles.config.api_key
      @cf = ::CloudFiles::Connection.new( :username => @username,
                                          :api_key  => @api_key )
    end

    def for( container )
      @cf.container( container )
    end

    def rubygems
      @cf.container( 'rubygems' )
    end

    def object_keys( container )
      objs = []
      last = nil
      total = container.count
      loop do
        info = container.list_objects( :marker => last, :limit => 10_000 )
        break if info.size == 0
        info.sort!
        first = info.first
        last  = info.last
        objs.concat( info )
        logger.info "Fetched [#{objs.size}/#{total}] keys #{first} .. #{last}"
        break if objs.size >= total
      end
      return objs
    end

    def object_info( container )
      objs = Hash.new
      last = nil
      total = container.count
      loop do
        info  = container.list_objects_info( :marker => last, :limit => 10_000 )
        break if info.size == 0
        keys = info.keys.sort
        first = keys.first
        last  = keys.last
        objs.merge!( info )

        logger.info "Fetched [#{objs.size}/#{total}] info #{first} .. #{last}"
        break if objs.size >= container.count
      end
      return objs
    end
  end
end
