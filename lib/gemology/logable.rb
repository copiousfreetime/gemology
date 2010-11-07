module Gemology

  def self.app_name
    @app_name || "gemology"
  end

  def self.app_name=( name )
    @app_name = name
  end

  class Logging
    def self.init
      unless @initialized then
        layout   = ::Logging::Layouts::Pattern.new( :pattern => "%5l %c : %m" )
        appender = ::Logging::Appenders::Syslog.new( Gemology.app_name,
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

  # for when you need ane explicit logging class instance
  class Logger
    include Logable
    %w[ info warn error debug fatal ].each do |m|
      module_eval <<-_code
        def #{m}(*args)
          logger.#{m}(*args)
        end
      _code
    end
  end
end
