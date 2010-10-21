require "win32/process"

module AutoGui

  class Application
    include AutoGui::Input

    attr_reader :name  
    attr_reader :title  
    attr_reader :main_window  
    
    @@titles = {}
    
    def initialize(name, options = {})
      @name = name
      @title = options[:title] || name

      start unless running?
    end
    
    # @returns main_window or nil if failed
    def start(options={})
      # returns a struct
      Process.create(
         :app_name => name,
         :creation_flags => Process::DETACHED_PROCESS
      )

      @main_window = Window.find title
      @main_window.set_focus if running?
      @main_window
    end

    def close(options={})
      main_window.close(options)
    end

    def running?
      main_window && (main_window.is_window?)
    end

  private

  end

end
