require 'resque/server'
require 'gemology/webhook'


#run Rack::URLMap.new(
#  "/webhook" => Gemology::Webhook::App.new,
#  "/resque"  => Resque::Server.new
#)
app = Rack::Builder.new do
  use ::Rack::CommonLogger
  use ::Rack::ShowExceptions

  map "/webhook" do
    run Gemology::Webhook::App.new
  end

  map "/resque" do
    run ::Resque::Server.new
  end
end
run app
