require 'log4r'

# Open up Log4r and add a simple log accessor for 'logfile'
#
# @example: allows simple setup
#
#   include Autogui::Logging
#
#   logger.filename = 'log/autogui.log'
#   logger.warn "warning messsage goes to log file"
#
module Log4r
  class Logger

    # @return [String] filename of the logfile
    def logfile
      @filename
    end

    def logfile=(fn)
      FileOutputter.new(:logfile, :filename => fn, :trunc => true)
      Outputter[:logfile].formatter = Log4r::PatternFormatter.new(:pattern => "[%5l %d] %M [%t]")
      add(:logfile)
    end

  end
end

module Autogui

  STANDARD_LOGGER = 'standard'

  # wrapper for Log4r gem
  module Logging

    # Logging mixin allows simple logging setup
    # to STDOUT and one filename.  Logger is a wrapper
    # for Log4r::Logger it accepts any methods that 
    # Log4r::Logger accepts in addition to the "logfile" filename.
    #
    # @example:  simple loggin setup to file
    #
    #   include Autogui::Logging
    #
    #   logger.filename = 'log/autogui.log'
    #   logger.warn "warning messsage goes to 'log/autogui.log'" 
    #
    #   logger.level = Log4r::DEBUG
    #   logger.debug "this message goes to 'log/autogui.log'"
    #
    def logger
      init_logger if Log4r::Logger[STANDARD_LOGGER].nil?
      Log4r::Logger[STANDARD_LOGGER]
    end


    protected
    
    # Initialize the logger, defaults to log4r::Warn
    def init_logger
      log = Log4r::Logger.new(STANDARD_LOGGER)
      Log4r::Logger[STANDARD_LOGGER].level = Log4r::WARN
      Log4r::Logger[STANDARD_LOGGER].trace = true

      Log4r::StderrOutputter.new :console
      Log4r::Outputter[:console].formatter = Log4r::PatternFormatter.new(:pattern => "[%l] %m")
      log.add(:console)
    end

  end
end
