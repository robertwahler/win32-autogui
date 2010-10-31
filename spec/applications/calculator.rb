require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class Calculator < Autogui::Application

  def initialize(name="calc", options = {:title=> "Calculator"})
    super name, options
  end

  def edit_window
    main_window.children.find {|w| w.window_class == 'Edit'}
  end

  def dialog_about
    Autogui::EnumerateDesktopWindows.new.find do |w| 
      w.title.match(/About Calculator/) && (w.pid == pid)
    end
  end

  def clear_entry
    set_focus
    keystroke(VK_DELETE)
  end

end
