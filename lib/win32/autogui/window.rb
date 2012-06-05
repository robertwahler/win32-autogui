require 'timeout'
require 'windows/window'
require 'windows/window/message'
require 'windows/window/classes'
require 'win32/autogui/windows/window'

module Autogui

  class FindTimeout < Timeout::Error; end

  # Enumerate desktop child windows
  #
  # Start at the desktop and work down through all the child windows
  #
  class EnumerateDesktopWindows
    include Enumerable
    include Windows::Window
    include Autogui::Logging

    # @return [Number] timeout (0) in seconds
    attr_accessor :timeout

    # @option options [Number] :timeout (0) maximum seconds to continue enumerating windows
    def initialize(options ={})
      @timeout = options[:timeout] || 0
    end

    # redefine Enumerable's find to continue looping until a timeout reached
    def find(ifnone = nil)
      return to_enum :find, ifnone unless block_given?

      begin
        Timeout.timeout(timeout, FindTimeout) do
          begin
            each { |o| return o if yield(o) }
            sleep 0.2 unless (timeout == 0)
            #logger.debug "find looping" unless (timeout == 0)
          end until (timeout == 0)
        end
      rescue FindTimeout
        logger.warn "EnumerateDesktopWindows.find timeout"
        nil
      end

      ifnone.call if ifnone
    end

    def each
      child_after = 0
      while (child_after = FindWindowEx(nil, child_after, nil, nil)) > 0 do
        yield Window.new child_after
      end
    end
  end

  # Enumerate just the child windows one level down from the parent window
  #
  class Children
    include Enumerable
    include Windows::Window

    # @param [Number] parent window handle
    #
    def initialize(parent)
      @parent = parent
    end

    # @yield [Window]
    #
    def each
      child_after = 0
      while (child_after = FindWindowEx(@parent.handle, child_after, nil, nil)) > 0 do
        window = Window.new child_after
        # immediate children only
        yield window if (window.parent) && (window.parent.handle == @parent.handle)
      end
    end
  end

  # Wrapper for window
  #
  class Window
    include Windows::Window           # instance methods from windows-pr gem
    include Windows::Window::Message  # PostMessage and constants
    include Windows::Window::Classes  # GetClassName
    include Autogui::Logging
    include Autogui::Input

    attr_reader :handle

    def initialize(handle)
      @handle = handle
    end

    # enumerable immeadiate child windows
    #
    # @see Children
    #
    def children
      Children.new(self)
    end

    # @return [Object] Window or nil
    #
    def parent
      h = GetParent(handle)
      Window.new h if h > 0
    end

    # PostMessage SC_CLOSE and optionally wait for the window to close
    #
    # @param [Hash] options
    # @option options [Boolean] :wait_for_close (true) sleep while waiting for timeout or close
    # @option options [Boolean] :timeout (5) wait_for_close timeout in seconds
    #
    def close(options={})
      PostMessage(handle, WM_SYSCOMMAND, SC_CLOSE, 0)
      wait_for_close(options) if (options[:wait_for_close] == true)
    end

    # Wait for the window to close
    #
    # @param [Hash] options
    # @option options [Boolean] :timeout (5) timeout in seconds
    #
    def wait_for_close(options={})
      seconds = options[:timeout] || 5
      timeout(seconds) do
        begin
          yield if block_given?
          sleep 0.05
        end until 0 == IsWindow(handle)
      end
    end

    # @return [String] the Windows ClassName
    #
    def window_class
      buffer = "\0" * 255
      length = GetClassName(handle, buffer, buffer.length)
      length == 0 ? '' : buffer[0..length - 1]
    end

    # Window text (GetWindowText or WM_GETTEXT)
    #
    # @param [Number] max_length (2048)
    #
    # @return [String] of max_length (2048)
    #
    def text(max_length = 2048)
      buffer = "\0" * max_length
      length = if is_control?
        SendMessageA(handle, WM_GETTEXT, buffer.length, buffer)
      else
        GetWindowText(handle, buffer, buffer.length)
      end

      length == 0 ? '' : buffer[0..length - 1]
    end
    alias :title :text

    # Determines whether the specified window handle identifies a window or a control
    #
    # @return [Boolean]
    #
    def is_control?
      (handle != 0) && (GetDlgCtrlID(handle) != 0)
    end

    # Determines whether the specified window handle identifies an existing window
    #
    # @return [Boolean]
    #
    def is_window?
      (handle != 0) && (IsWindow(handle) != 0)
    end

    # Determines the visibility state of the window
    #
    # @return [Boolean]
    #
    def visible?
      is_window? && (IsWindowVisible(handle) != 0)
    end

    # Brings the window into the foreground and activates it.
    # Keyboard input is directed to the window, and various visual cues
    # are changed for the user.
    #
    # A process can set the foreground window only if one of the following conditions is true:
    #
    #    * The process is the foreground process.
    #    * The process was started by the foreground process.
    #    * The process received the last input event.
    #    * There is no foreground process.
    #    * The foreground process is being debugged.
    #    * The foreground is not locked.
    #    * The foreground lock time-out has expired.
    #    * No menus are active.
    #
    # @return [Number] nonzero number if sucessful, nil or zero if failed
    #
    def set_focus
      if is_window?
        # if current process was the last to receive input, we can be sure that
        # SetForegroundWindow will be allowed.  Send the shift key to whatever has
        # the focus now.  This allows IRB to set_focus.
        keystroke(VK_SHIFT)
        ret = SetForegroundWindow(handle)
        logger.warn("SetForegroundWindow failed") if ret == 0
      end
    end

    # The identifier (pid) of the process that created the window
    #
    # @return [Integer] process id if the window exists, otherwise nil
    #
    def pid
      return nil unless is_window?
      process_id = 0.chr * 4
      GetWindowThreadProcessId(handle, process_id)
      process_id = process_id.unpack('L').first
    end

    # The identifier of the thread that created the window
    #
    # @return [Integer] thread id if the window exists, otherwise nil
    #
    def thread_id
      return nil unless is_window?
      GetWindowThreadProcessId(handle, nil)
    end

    # The window text including all child windows
    # joined together with newlines. Faciliates matching text.
    # Text from any given window is limited to 2048 characters
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
      return unless is_window?
      t = []
      t << text unless text == ''
      children.each do |w|
        t << w.combined_text unless w.combined_text == ''
      end
      t.join("\n")
    end

    # Debugging information
    #
    # @return [String] with child window information
    def inspect
      c = []
      children.each do |w|
        c << w.inspect
      end
      s = super + " #{self.class}=<window_class:#{window_class} pid:#{pid} thread_id:#{thread_id} title:\"#{title}\" children=<" + c.join("\n") + ">>"
    end

  end

end
