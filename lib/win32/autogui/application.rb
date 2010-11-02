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
    def text 
      Win32::Clipboard.data
    end

    # Clipboard text setter
    #
    # @param [String] str text to load onto the clipboard
    def text=(str)
      Win32::Clipboard.set_data(str)
    end

  end

  # Application class wraps a binary application so 
  # that it can be started and controlled via Ruby.  This
  # class is meant to be subclassed.
  #
  # TODO: Version 1.0 will be implemented as a mixin.
  #
  # @example
  #
  #   class Calculator < Autogui::Application
  #
  #     def initialize(name="calc", options = {:title=> "Calculator"})
  #       super name, options
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

    # @return [String] the executable name of the application
    attr_reader :name  
    # @return [String] the executable application parameters 
    attr_reader :parameters  
    # @return [String] window title of the application
    attr_accessor :title  
    # @return [Number] the process identifier (PID) returned by Process.create
    attr_reader :pid
    # @return [Number] the process thread id returned by Process.create
    attr_reader :thread_id
    # @return [Number] the main_window wait timeout in seconds
    attr_accessor :main_window_timeout
    
    # @example initialize an application on the path
    #
    #   Application.new "calc"  
    #
    # @example initialize with full DOS path
    #
    #   Application.new "\\windows\\system32\\calc.exe"  
    #
    # @param [String] name a valid win32 exe name with optional path
    # @param [Hash] options initialize options passed to start method
    # @option options [String] :title (Application.name) the application window title, used along with the pid to locate the application main window
    # @option options [Number] :create_process_timeout (10) timeout in seconds to wait for the create_process to return 
    # @option options [Number] :main_window_timeout (10) timeout in seconds to wait for main_window to appear
    def initialize(name, options = {})

      @name = name
      @title = options[:title] || name
      @main_window_timeout = options[:main_window_timeout] || 10
      @parameters = options[:parameters]

      start(options)
    end
    
    # Start up the binary application via Process.create and
    # set the window focus to the main_window
    #
    # @raise [Exception] if create_process_timeout exceeded
    # @raise [Exception] if start failed for any reason other than create_process_timeout
    #
    # @return [Window] main_window or nil if failed
    # @param [Hash] options @see initialize
    def start(options={})
      
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

      create_process_timeout = options[:create_process_timeout] || 10
      
      # wait for process
      ret = WaitForInputIdle(process_handle, (create_process_timeout * 1000))

      # done with the handles
      CloseHandle(process_handle)
      CloseHandle(thread_handle)

      raise "Start command failed on create_process_timeout" if ret == WAIT_TIMEOUT 
      raise "Start command failed while waiting for idle input, reason unknown" unless (ret == 0)
    end

    # The application main window found by enumerating windows 
    # by title and application pid.  This method will keep looking
    # unit main_window_timeout (default: 10s) is exceeded.
    #
    # @raise [Exception] if the main window cannot be found
    #
    # @return [Autogui::Window]
    # @see initialize for options
    def main_window
      return @main_window if @main_window

      timeout(main_window_timeout) do
        begin
          # There may be multiple instances, use title and pid to id our main window
          @main_window = Autogui::EnumerateDesktopWindows.new.find do |w| 
            w.title.match(title) && w.pid == pid 
          end
          sleep 0.1 
         end until @main_window
      end

      # sanity checks
      raise "cannot find main_window, check application title" unless @main_window

      @main_window
    end

    # Call the main_window's close method
    #
    # PostMessage SC_CLOSE and optionally wait for the window to close
    #
    # @param [Hash] options
    # @option options [Boolean] :wait_for_close (true) sleep while waiting for timeout or close
    # @option options [Boolean] :timeout (5) wait_for_close timeout in seconds
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
    def clipboard
      @clipboard || Autogui::Clipboard.new
    end

  private

  end

end
