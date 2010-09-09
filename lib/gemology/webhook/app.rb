require 'sinatra'
require 'gemology/logable'
require 'gemology/fetch_store_job'
require 'resque'
require 'json'

module Gemology::Webhook
  # A sinatra app for accepting webhook posts from rubygems.org and 
  #
  # == Options
  class App < ::Sinatra::Base

    include Gemology::Logable

    def initialize( app = nil, options = {} )
      @app = app
      super( @app )
      if options[:redis] then
        Resque.redis = options[:redis]
      end
      @redis = Resque.redis
    end

    get '/accept' do
      error(405, "I think you want a POST request")
    end

    post '/accept' do
      begin
        submit_job( request.body.read )
        halt 202
      rescue => e
        logger.error e.message
        e.backtrace.each do |b|
          logger.debug b
        end
        error(500, e.message)
      end
    end

    def submit_job( json )
      data = ::JSON.parse( json )
      uri = data['gem_uri']
      logger.info "Submitting #{uri}"
      Resque.enqueue( ::Gemology::FetchStoreJob,  uri )
    end
  end
end
