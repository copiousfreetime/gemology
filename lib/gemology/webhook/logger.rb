require 'gemology/logable'
module Gemology::Webhook
  class Logger

    include Gemology::Logable

    def initialize( app, opts = {} )
      @app = app
      @level = opts[:level] || :info
      @logger = self.logger
    end

    def call( env )
      env['rack.logger'] = @logger
      @app.call( env )
    end
  end
end
