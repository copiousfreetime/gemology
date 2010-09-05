require 'sinatra'
require 'gemology/webhook/job'
module Gemology::Webhook
  # A sinatra app for accepting webhook posts from rubygems.org and 
  #
  # == Options
  class App < ::Sinatra::Base

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
        log e.message
        e.backtrace.each do |b|
          log b
        end
        error(500, e.message)
      end
    end

    def log( msg )
      env['rack.errors'].puts msg
    end

    def submit_job( json )
      log "Submitting >>#{json}<<"
      Resque.enqueue( ::Gemology::Webhook::Job, json )
    end
  end
end
