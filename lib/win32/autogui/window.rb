require 'windows/window'
require 'windows/window/message'

# Reopen module and supply missing constants and 
# functions from windows-pr gem
#
# TODO: Fork and send pull request for Windows::Window module, be sure to lock bundle before sending request
#
module Windows
  module Window

    SC_CLOSE = 0xF060

    API.auto_namespace = 'Windows::Window'
    API.auto_constant  = true
    API.auto_method    = true
    API.auto_unicode   = false

    API.new('IsWindow', 'L', 'I', 'user32')
    API.new('SetForegroundWindow', 'L', 'I', 'user32')
    API.new('SendMessageA', 'LIIP', 'I', 'user32')
    API.new('GetClassNameA', 'LPI', 'I', 'user32')

  end
end

module Autogui

  # Enumerate desktop child windows
  #
  # Start at the desktop and work down through all the child windows
  #
  class EnumerateDesktopWindows
    include Enumerable
    include Windows::Window

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
        yield window if (window.parent.handle == @parent.handle)
      end
    end
  end

  # Wrapper for window
  #
  class Window
    include Windows::Window           # instance methods from windows-pr gem
    include Windows::Window::Message  # PostMessage and constants

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
        sleep 0.05 until 0 == IsWindow(handle)
      end
    end

    # @return [String] the ANSI Windows ClassName
    # 
    def window_class
      buffer = "\0" * 255
      length = GetClassNameA(handle, buffer, buffer.length)
      length == 0 ? '' : buffer[0..length - 1]
    end

    # Window text (WM_GETTEXT)
    #
    # @param [Number] max_length (2048)
    #
    # @return [String] of max_length (2048)
    #
    def text(max_length = 2048)
      buffer = "\0" * max_length
      length = SendMessageA(handle, WM_GETTEXT, buffer.length, buffer)
      length == 0 ? '' : buffer[0..length - 1]
    end
    alias :title :text

    # Determines whether the specified window handle identifies an existing window 
    #
    # @return [Boolean]
    #
    def is_window?
      (handle != 0) && (IsWindow(handle) != 0)
    end
    
    # Brings the window into the foreground and activates it. 
    # Keyboard input is directed to the window, and various visual cues 
    # are changed for the user.
    #
    # @return [Number] nonzero number if sucessful, nil or zero if failed
    #
    def set_focus
      SetForegroundWindow(handle) if is_window?
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
