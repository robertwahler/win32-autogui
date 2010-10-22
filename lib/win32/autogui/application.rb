require 'windows/process'
require 'windows/synchronize'
require 'windows/handle'
require "win32/process"

module Autogui

  class Application
    include Windows::Process           
    include Windows::Synchronize
    include Windows::Handle

    attr_reader :name  
    attr_reader :title  
    attr_reader :main_window  
    attr_reader :pid
    attr_reader :thread_id
    
    def initialize(name, options = {})
      @name = name
      @title = options[:title] || name

      # TODO: implement Application.find and add option to not start automatically
      start
    end
    
    # @returns main_window or nil if failed
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

      # done with the handles, close them
      CloseHandle(process_handle)
      CloseHandle(thread_handle)

      raise "Start command failed on timeout" if ret == WAIT_TIMEOUT 
      raise "Start command failed while waiting for idle input, reason unknown" unless (ret == 0)

      # There may be multiple instances, use title and pid to id our main window
      @main_window = Autogui::EnumerateDesktopWindows.new.find do |w| 
        w.title == title && w.pid == pid 
      end
      @main_window.set_focus if running?
      @main_window
    end

    def close(options={})
      main_window.close(options)
    end

    def running?
      main_window && (main_window.is_window?)
    end

    def set_focus
      main_window.set_focus if running? 
    end

    # The main_window text including all child windows 
    # joined together with newlines. Faciliates matching text.
    def combined_text
      main_window.combined_text if running? 
    end

  private

  end

end
