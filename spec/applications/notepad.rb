require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class Notepad < Autogui::Application

  # initialize with the binary name 'notepad' and the window title
  # '<filename> - Notepad' used along with the application pid to find the
  # main application window
  def initialize(options = {})
    defaults = {
                 :name => "notepad",
                 :title => " - Notepad",
                 :logger_level => Autogui::Logging::DEBUG
               }
    super defaults.merge(options)
  end

  # timeout in seconds to wait for desktop windows to appear
  def default_window_timeout
    1
  end

  # the notepad's results window
  def edit_window
    main_window.children.find {|w| w.window_class == 'Edit'}
  end

  # About dialog, hotkey (VK_MENU, VK_H, VK_A)
  def dialog_about(options = {})
    options[:timeout] = default_window_timeout unless options[:timeout]
    Autogui::EnumerateDesktopWindows.new(options).find do |w|
      w.title.match(/About Notepad/) && (w.pid == pid)
    end
  end

  def message_dialog_confirm(options={})
    options[:timeout] = default_window_timeout unless options[:timeout]
    Autogui::EnumerateDesktopWindows.new(options).find do |w|
      w.title.match(/Notepad/) && (w.pid == pid) && (w.window_class == "#32770")
    end
  end

  # menu action File, Exit
  def file_exit
    set_focus
    keystroke(VK_MENU, VK_F, VK_X)
    if message_dialog_confirm(:timeout => 0)
      keystroke(VK_N)
    end
  end

  # menu action File, Save
  def file_save
    set_focus
    keystroke(VK_MENU, VK_F, VK_S)
  end


end
