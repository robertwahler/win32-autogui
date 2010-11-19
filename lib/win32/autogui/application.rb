require 'timeout'
require 'windows/process'
require 'windows/synchronize'
require 'windows/handle'
require "win32/process"
require "win32/clipboard"

module Autogui

  # Wrapper class for text portion of the RubyGem win32/clipboard 
  # @see http://github.com/djberg96/win32-clipboard
  class Clipboard

    # Clipboard text getter
    # 
    # @return [String] clipboard data
    #
    def text 
      Win32::Clipboard.data
    end

    # Clipboard text setter
    #
    # @param [String] str text to load onto the clipboard
    #
    def text=(str)
      Win32::Clipboard.set_data(str)
    end

  end

  # The Application class wraps a binary application so 
  # that it can be started and controlled via Ruby.  This
  # class is meant to be subclassed.
  #
  # @example
  #
  #   class Calculator < Autogui::Application
  #
  #     def initialize(options = {})
  #       defaults = {
  #                    :name => "calc",
  #                    :title => "Calculator",
  #                    :logger_logfile => 'log/calc.log'
  #                  }
  #       super defaults.merge(options)
  #     end
  #
  #     def edit_window
  #       main_window.children.find {|w| w.window_class == 'Edit'}
  #     end
  #
  #     def dialog_about
  #       Autogui::EnumerateDesktopWindows.new.find do |w| 
  #         w.title.match(/About Calculator/) && (w.pid == pid)
  #       end
  #     end
  #
  #     def clear_entry
  #       set_focus
  #       keystroke(VK_DELETE)
  #     end
  #   end
  #
  class Application
    include Windows::Process           
    include Windows::Synchronize
    include Windows::Handle
    include Autogui::Logging

    # @return [String] the executable name of the application
    attr_accessor :name  
    
    # @return [String] the executable application parameters 
    attr_accessor :parameters  
    
    # @return [String] window title of the application
    attr_accessor :title  

    # @return [Number] the process identifier (PID) returned by Process.create
    attr_reader :pid

    # @return [Number] the process thread id returned by Process.create
    attr_reader :thread_id

    # @return [Number] the main_window wait timeout in seconds
    attr_accessor :main_window_timeout
    
    # @return [Number] the wait timeout in seconds used by Process.create
    attr_accessor :create_process_timeout
    
    # @example initialize an application on the path
    #
    #   app = Application.new :name => "calc"  
    #
    # @example initialize with relative DOS path
    #
    #   app = Application.new :name => "binaries\\mybinary.exe"  
    #
    # @example initialize with full DOS path
    #
    #   app = Application.new :name => "\\windows\\system32\\calc.exe"  
    #
    # @example initialize with logging to file at the default WARN level  (STDOUT logging is the default)
    #
    #   app = Application.new :name => "calc", :logger_logfile => 'log/calc.log' 
    #
    # @example initialize with logging to file at DEBUG level
    #
    #   include Autogui::Logging
    #   app = Application.new :name => "calc", :logger_logfile => 'log/calc.log', :logger.level => Autogui::Logging::DEBUG
    #
    # @example initialize without logging to file and turn it on later
    #
    #   include Autogui::Logging
    #   app = Application.new :name => "calc"
    #   logger.logfile = 'app.log'
    #
    # @param [Hash] options initialize options
    # @option options [String] :name a valid win32 exe name with optional path
    # @option options [String] :title the application window title, used along with the pid to locate the application main window, defaults to :name
    # @option options [Number] :parameters command line parameters used by Process.create
    # @option options [Number] :create_process_timeout (10) timeout in seconds to wait for the create_process to return 
    # @option options [Number] :main_window_timeout (10) timeout in seconds to wait for main_window to appear
    # @option options [String] :logger_logfile (nil) initialize logger's output filename
    # @option options [String] :logger_level (Autogui::Logging::WARN) initialize logger's initial level
    #
    def initialize(options = {})

      unless options.kind_of?(Hash)
        raise_error ArgumentError, 'Initialize expecting options to be a Hash'
      end

      @name = options[:name] || name
      @title = options[:title] || name
      @main_window_timeout = options[:main_window_timeout] || 10
      @create_process_timeout = options[:create_process_timeout] || 10
      @parameters = options[:parameters]

      # logger setup
      logger.logfile = options[:logger_logfile] if options[:logger_logfile]
      logger.level = options[:logger_level] if options[:logger_level]

      # sanity checks
      raise_error 'application name not set' unless name 

      start
    end
    
    # Start up the binary application via Process.create and
    # set the window focus to the main_window
    #
    # @raise [Exception] if create_process_timeout exceeded
    # @raise [Exception] if start failed for any reason other than create_process_timeout
    #
    # @return [Number] the pid
    #
    def start
      
      command_line = name
      command_line = name + ' ' + parameters if parameters

      # returns a struct, raises an error if fails
      process_info = Process.create(
         :command_line => command_line,
         :close_handles => false,
         :creation_flags => Process::DETACHED_PROCESS
      )
      @pid = process_info.process_id
      @thread_id = process_info.thread_id
      process_handle = process_info.process_handle
      thread_handle = process_info.thread_handle

      # wait for process
      ret = WaitForInputIdle(process_handle, (create_process_timeout * 1000))

      # done with the handles
      CloseHandle(process_handle)
      CloseHandle(thread_handle)

      raise_error "start command failed on create_process_timeout" if ret == WAIT_TIMEOUT 
      raise_error "start command failed while waiting for idle input, reason unknown" unless (ret == 0)
      @pid
    end

    # The application main window found by enumerating windows 
    # by title and application pid.  This method will keep looking
    # unit main_window_timeout (default: 10s) is exceeded.
    #
    # @raise [Exception] if the main window cannot be found
    #
    # @return [Autogui::Window]
    # @see initialize for options
    # 
    def main_window
      return @main_window if @main_window

      # pre sanity checks
      raise_error "calling main_window without a pid, application not initialized properly" unless @pid
      raise_error "calling main_window without a window title, application not initialized properly" unless @title

      timeout(main_window_timeout) do
        begin
          # There may be multiple instances, use title and pid to id our main window
          @main_window = Autogui::EnumerateDesktopWindows.new.find do |w| 
            w.title.match(title) && w.pid == pid 
          end
          sleep 0.1 
        end until @main_window
      end

      # post sanity checks
      raise_error "cannot find main_window, check application title" unless @main_window

      @main_window
    end

    # Call the main_window's close method
    #
    # PostMessage SC_CLOSE and optionally wait for the window to close
    #
    # @param [Hash] options
    # @option options [Boolean] :wait_for_close (true) sleep while waiting for timeout or close
    # @option options [Boolean] :timeout (5) wait_for_close timeout in seconds
    #
    def close(options={})
      main_window.close(options)
    end

    # Send SIGKILL to force the application to die
    def kill
      Process::kill(9, pid)
    end

    # @return [Boolean] if the application is currently running
    def running?
      main_window && (main_window.is_window?)
    end

    # Set the application input focus to the main_window
    # 
    # @return [Number] nonzero number if sucess, nil or zero if failed
    # 
    def set_focus
      main_window.set_focus if running? 
    end

    # The main_window text including all child windows 
    # joined together with newlines. Faciliates matching text.
    #
    # @example partial match of the Window's calulator's about dialog copywrite text
    #
    #   dialog_about = @calculator.dialog_about
    #   dialog_about.title.should == "About Calculator"
    #   dialog_about.combined_text.should match(/Microsoft . Calculator/)
    #
    # @return [String] with newlines
    #
    def combined_text
      main_window.combined_text if running? 
    end

    # @example set the clipboard text and paste it with Control-V
    #
    #   @calculator.edit_window.set_focus
    #   @calculator.clipboard.text = "12345"
    #   @calculator.edit_window.text.strip.should == "0."
    #   keystroke(VK_CONTROL, VK_V) 
    #   @calculator.edit_window.text.strip.should == "12,345."
    #
    # @return [Clipboard] 
    #
    def clipboard
      @clipboard || Autogui::Clipboard.new
    end

    private

    # @overload raise_error(exception, message)
    #   raise and log specific exception with message
    #   @param [Exception] to raise
    #   @param [String] message error message to raise
    #
    # @overload raise_error(message)
    #   raise and log generic exception with message
    #   @param [String] message error message to raise
    #
    def raise_error(*args)
      if args.first.kind_of?(Exception)
        exception_type = args.shift
        error_message = args.shift || 'Unknown error'
      else
        raise ArgumentError unless args.first.is_a?(String)
        exception_type = RuntimeError
        error_message = args.shift || 'Unknown error'
      end

      logger.error error_message
      raise  exception_type, error_message
    end

  end

end
