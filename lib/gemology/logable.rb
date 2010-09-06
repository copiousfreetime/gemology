require 'logging'
module Gemology

  class Logging
    def self.init
      unless @initialized then
        layout   = ::Logging::Layouts::Pattern.new( :pattern => "%5l %c : %m" )
        appender = ::Logging::Appenders::Syslog.new( File.basename( $0 ), 
                                                    :logopt => ::Syslog::Constants::LOG_CONS | ::Syslog::Constants::LOG_PID, 
                                                    :facility => ::Syslog::Constants::LOG_LOCAL0,
                                                    :layout => layout)
        gemology_logger = ::Logging::Logger[Gemology]
        ::Logging::Appenders['syslog'] = appender
        gemology_logger.add_appenders( appender )
        @initialized = true
      end
      return @initialized
    end
  end

  module Logable
    def logger
      Gemology::Logging.init
      ::Logging::Logger[self]
    end
  end
end
