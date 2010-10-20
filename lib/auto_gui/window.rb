require 'windows/window'
require 'windows/window/message'

# Reopen module and supply missing constants and 
# functions from windows-pr gem
#
# TODO: Fork and send pull request 
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

module AutoGui

  class Children
    include Enumerable
    include Windows::Window

    def initialize(parent)
      @parent = parent
    end

    def each
      child_after = 0
      while (child_after = FindWindowEx(@parent.handle, child_after, nil, nil)) > 0 do
        window = Window.new child_after
        # immediate children only
        yield window if (window.parent.handle == @parent.handle)
      end
    end
  end

  class Window
    include Windows::Window           # instance methods from windows-pr gem
    include Windows::Window::Message  # PostMessage and constants
    extend Windows::Window            # class methods from windows-pr gem

    attr_reader :handle

    def initialize(handle)
      @handle = handle
    end
    
    def self.find(title, seconds=10, window_class = nil)
      handle = timeout(seconds) do
        loop do
          h = FindWindow(window_class, title)
          break h if h > 0
          sleep 0.3
        end
      end

      Window.new handle
    end

    def children
      Children.new(self)
    end

    def parent
      h = GetParent(handle)
      Window.new h if h > 0
    end

    def close(options={})
      PostMessage(handle, WM_SYSCOMMAND, SC_CLOSE, 0)

      wait_for_close = (options[:wait_for_close] == true) ? true : false
      seconds = options[:timeout] || 5
      if wait_for_close 
        timeout(seconds) do
          sleep 0.05 until 0 == IsWindow(handle)
        end
      end
    end

    def window_class
      buffer = "\0" * 255
      length = GetClassNameA(handle, buffer, buffer.length)
      length == 0 ? '' : buffer[0..length - 1]
    end

    def text(max_length = 512)
      buffer = "\0" * max_length
      length = SendMessageA(handle, WM_GETTEXT, buffer.length, buffer)
      length == 0 ? '' : buffer[0..length - 1]
    end

    def title
      text
    end

    def inspect
      c = [] 
      children.each do |w| 
        c << "@window_class: #{w.window_class} @title: \"#{w.title}\""
      end
      s = "#{self.class} @window_class: #{window_class} @title: \"#{title}\" @children=" + c.join(', ')
    end

  end

end
