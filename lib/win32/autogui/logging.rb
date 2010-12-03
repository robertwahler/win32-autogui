require 'log4r'

# Open up Log4r and add a simple log accessor for 'logfile'
#
# @example allows simple setup
#
#   include Autogui::Logging
#
#   logger.filename = 'log/autogui.log'
#   logger.warn "warning message goes to log file"
#
module Log4r
  class Logger

    # @return [String] filename of the logfile
    def logfile
      @filename
    end

    def logfile=(fn)
      if fn == nil
        puts "removing log to file"
        remove(:logfile) if @filename
      else
        FileOutputter.new(:logfile, :filename => fn, :trunc => true)
        Outputter[:logfile].formatter = Log4r::PatternFormatter.new(:pattern => "[%5l %d] %M [%t]")
        add(:logfile)
      end
      @filename = fn
    end

  end
end

module Autogui

  # wrapper for Log4r gem
  module Logging

    # Redefine logging levels so that they can be accessed before
    # the logger is initialized at the expense of flexibility.
    DEBUG = 1
    INFO = 2
    WARN = 3
    ERROR = 4
    FATAL = 5

    STANDARD_LOGGER = 'standard'

    # Logging mixin allows simple logging setup
    # to STDOUT and optionally, to one filename.  Logger is a wrapper
    # for Log4r::Logger it accepts any methods that
    # Log4r::Logger accepts in addition to the "logfile" filename.
    #
    # @example  simple logging to file setup
    #
    #   include Autogui::Logging
    #
    #   logger.filename = 'log/autogui.log'
    #   logger.warn "warning message goes to 'log/autogui.log'"
    #
    #   logger.level = Autogui::Logging::DEBUG
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

      # sanity checks since we defined log4r's dynamic levels statically
      unless (Log4r::DEBUG == DEBUG) &&
             (Log4r::INFO == INFO) &&
             (Log4r::WARN == WARN) &&
             (Log4r::ERROR == ERROR) &&
             (Log4r::FATAL == FATAL)
        raise "Logger levels do not match Log4r levels, levels may have been customized"
      end

      Log4r::Logger[STANDARD_LOGGER].level = WARN
      Log4r::Logger[STANDARD_LOGGER].trace = true

      Log4r::StderrOutputter.new :console
      Log4r::Outputter[:console].formatter = Log4r::PatternFormatter.new(:pattern => "[%l] %m")
      log.add(:console)
    end

  end
end
