require 'gemology/webhook'
require 'resque/server'

module Gemology
  class Web
    def initialize( gemology_root = nil )
      @gemology_root = File.expand_path( gemology_root ) if gemology_root
    end

    def app
      Rack::Builder.new do
        use ::Gemology::Webhook::Logger, :level => :debug
        use ::Rack::CommonLogger

        map "/webhook" do
          run Gemology::Webhook::App.new
        end

        map "/resque" do
          run ::Resque::Server.new
        end
      end
    end
  end
end
