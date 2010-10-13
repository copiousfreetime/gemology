require 'gemology/logable' 
require 'gemology/spec_lite'
require 'httparty'
require 'cloudfiles'
require 'digest/md5'

module Gemology
  #
  # This is is a Resque job
  #
  class FetchStoreJob
    include ::Gemology::Logable

    def self.queue
      "fetch_store"
    end

    def self.container
      unless @container then
        cf = ::CloudFiles::Connection.new( :username => "copiousfreetime", :api_key => "cbf15dfbf487d9b00706ed18940dca8e" )
        @container = cf.container( 'rubygems' )
      end
      return @container
    end

    def self.perform( url )
      job = FetchStoreJob.new( url )
      job.run
    end


    def initialize( url )
      @url = url 
      logger.info "Starting fetch and store of #{@url}"
    end

    def container
      FetchStoreJob.container
    end

    def run
      fname = File.basename( URI.parse( @url ).path )

      logger.info "Fetching #{@url}"
      resp = HTTParty.get( @url )

      logger.info "Storing #{fname}"
      obj = container.create_object( fname )

      if obj.write( resp.body ) then
        logger.info "Finished fetch and store of #{@url}"
      else
        logger.error "Woops, had a problem, not sure what with #{@url}"
      end
    rescue => e
      logger.error e
      e.backtrace.each { |b| logger.debug b }
      raise e
    end
  end
end
