require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class Calculator < Autogui::Application

  # initialize with the binary name 'calc' and the window title
  # 'Calculator' used along with the application pid to find the 
  # main application window
  def initialize(options = {})
    defaults = {
                 :name => "calc",
                 :title => "Calculator"
               }
    super defaults.merge(options)
  end

  # the calculator's results window 
  def edit_window
    main_window.children.find {|w| w.window_class == 'Edit'}
  end

  # About dialog, hotkey (VK_MENU, VK_H, VK_A)
  def dialog_about
    Autogui::EnumerateDesktopWindows.new.find do |w| 
      w.title.match(/About Calculator/) && (w.pid == pid)
    end
  end

  # the 'CE' button
  def clear_entry
    set_focus
    keystroke(VK_DELETE)
  end

end
