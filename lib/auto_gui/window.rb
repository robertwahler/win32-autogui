require 'windows/window'
require 'windows/window/message'

# Missing constants and functions from windows-pr gem
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

  end
end

module AutoGui

  class Window
    # instance methods from windows-pr gem
    include Windows::Window
    include Windows::Window::Message
    # class methods from windows-pr gem
    extend Windows::Window

    attr_accessor :handle
    attr_accessor :window_class

    def initialize(handle, window_class = nil)
      @handle = handle
      @window_class = window_class
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

    def close
      PostMessage(handle, WM_SYSCOMMAND, SC_CLOSE, 0)
    end

  end

end
