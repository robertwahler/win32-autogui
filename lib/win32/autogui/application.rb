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
    # @return [String] window title of the appliation
    attr_reader :title  
    # @return [Number] the process identifier (PID) returned by Process.create
    attr_reader :pid
    # @return [Number] the process thread id returned by Process.create
    attr_reader :thread_id
    
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
    # @option options [Number] :wait_for_close (10000) (10 secs) timeout for starting application in msec

    #   :wait_for_close [Number]     #
    def initialize(name, options = {})
      @name = name
      @title = options[:title] || name

      start(options)
    end
    
    # Start up the binary application via Process.create and
    # set the window focus to the main_window
    #
    # @raise [Exception] if :wait_for_close timeout exceeded
    # @raise [Exception] if start failed for any reason other than timeout
    #
    # @return [Window] main_window or nil if failed
    # @param [Hash] options @see initialize
    def start(options={})
      
      # returns a struct, raises an error if fails
      process_info = Process.create(
         :app_name => name,
         :close_handles => false,
         :creation_flags => Process::DETACHED_PROCESS
      )
      @pid = process_info.process_id
      @thread_id = process_info.thread_id
      process_handle = process_info.process_handle
      thread_handle = process_info.thread_handle

      timeout = options[:wait_for_close] || 10000
      
      # wait for process before enumerating windows
      ret = WaitForInputIdle(process_handle, timeout)

      # done with the handles
      CloseHandle(process_handle)
      CloseHandle(thread_handle)

      raise "Start command failed on timeout" if ret == WAIT_TIMEOUT 
      raise "Start command failed while waiting for idle input, reason unknown" unless (ret == 0)

      # TODO: raise if set_focus fails to return success, suspect window title at this point
      set_focus
    end

    # The application main window found by enumerating windows by title and pid
    #
    # @return [Autogui::Window] or nil if not found
    def main_window
      return @main_window if @main_window

      # There may be multiple instances, use title and pid to id our main window
      @main_window = Autogui::EnumerateDesktopWindows.new.find do |w| 
        w.title.match(title) && w.pid == pid 
      end
    end

    def close(options={})
      main_window.close(options)
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
