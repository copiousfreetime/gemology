module Gemology::Webhook
  #
  # This is is a Resque job
  #
  class Job
    def self.queue
      "webhook"
    end

    def self.perform( params )
      puts params.to_s
    end
  end
end
