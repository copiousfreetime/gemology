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
      puts "Initialized"
    end

    post '/accept' do
      begin
        data = request.body.read
        puts data
        Resque.enqueue( ::Gemology::Webhook::Job, data )
        halt 202
      rescue => e
        puts e
        puts e.backtrace
        error(500, e.message)
      end
    end
  end
end
