require 'win32/autogui'

APPNAME="exe\\myapp.exe"  # relative path to app using Windows style path

class Myapp < Autogui::Application

  def initialize(options = {})
    # relative path to app using Windows style path
    @name ="exe\\myapp.exe"  
    defaults = {
                 :title=> "MyApp -", 
                 :parameters => '--nosplash', 
                 :main_window_timeout => 20
               }
    super defaults.merge(options)
  end

  def edit_window
    main_window.children.find {|w| w.window_class == 'TMemo'}
  end

  def status_bar
    main_window.children.find {|w| w.window_class == 'TStatusBar'}
  end

  def dialog_about(options={})
    Autogui::EnumerateDesktopWindows.new(options).find do |w| 
      w.title.match(/About MyApp/) && (w.pid == pid)
    end
  end

  def message_dialog_confirm(options={})
    Autogui::EnumerateDesktopWindows.new(options).find do |w| 
      w.title.match(/Confirm/) && (w.pid == pid)
    end
  end

  # Title and class are the same as dialog_overwrite_confirm
  # Use child windows to differentiate
  def dialog_overwrite_confirm(options={})
    Autogui::EnumerateDesktopWindows.new(options).find do |w| 
      w.title.match(/^Text File Save$/) && 
        (w.pid == pid) && 
        (w.window_class == "#32770") &&
        (w.combined_text.match(/already exists/))
    end
  end

  # title and class are the same as dialog_overwrite_confirm
  def file_save_as_dialog(options={})
    Autogui::EnumerateDesktopWindows.new(options).find do |w| 
      w.title.match(/Text File Save/) && 
        (w.pid == pid) &&
        (w.window_class == "#32770") &&
        (w.combined_text.match(/Save \&in:/))
    end
  end

  def file_open_dialog(options={})
    Autogui::EnumerateDesktopWindows.new(options).find do |w| 
      w.title.match(/Text File Open/) && (w.pid == pid)
    end
  end

  def error_dialog(options={})
    Autogui::EnumerateDesktopWindows.new(options).find do |w| 
      w.title.match(/^MyApp$/) && (w.pid == pid) && (w.window_class == "#32770")
    end
  end

  # menu action File, Exit
  def file_exit
    set_focus
    keystroke(VK_N) if message_dialog_confirm 
    keystroke(VK_ESCAPE) if file_open_dialog
    keystroke(VK_MENU, VK_F, VK_X) 
    keystroke(VK_N) if message_dialog_confirm 
  end
  
end
