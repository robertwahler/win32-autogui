# use the development version of win32-autogui
# Production code should simply require 'win32/autogui'
require File.expand_path(File.dirname(__FILE__) + '/../../../lib/win32/autogui')


class Quicknote < Autogui::Application

  def initialize(options = {})
    # relative path to app using Windows style path
    @name ="exe\\quicknote.exe"  
    defaults = {
                 :title=> "QuickNote -", 
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

  def dialog_about
    Autogui::EnumerateDesktopWindows.new.find do |w| 
      w.title.match(/About QuickNote/) && (w.pid == pid)
    end
  end

  def splash
    Autogui::EnumerateDesktopWindows.new.find do |w| 
      w.title.match(/FormSplash/) && (w.pid == pid)
    end
  end

  def message_dialog_confirm
    Autogui::EnumerateDesktopWindows.new.find do |w| 
      w.title.match(/Confirm/) && (w.pid == pid)
    end
  end

  # Title and class are the same as dialog_overwrite_confirm
  # Use child windows to differentiate
  def dialog_overwrite_confirm
    Autogui::EnumerateDesktopWindows.new.find do |w| 
      w.title.match(/^Text File Save$/) && 
        (w.pid == pid) && 
        (w.window_class == "#32770") &&
        (w.combined_text.match(/already exists/))
    end
  end

  # Title and class are the same as dialog_overwrite_confirm
  def file_save_as_dialog
    Autogui::EnumerateDesktopWindows.new.find do |w| 
      w.title.match(/Text File Save/) && 
        (w.pid == pid) &&
        (w.window_class == "#32770") &&
        (w.combined_text.match(/Save \&in:/))
    end
  end

  def file_open_dialog
    Autogui::EnumerateDesktopWindows.new.find do |w| 
      w.title.match(/Text File Open/) && (w.pid == pid)
    end
  end

  def error_dialog
    Autogui::EnumerateDesktopWindows.new.find do |w| 
      w.title.match(/^QuickNote$/) && (w.pid == pid) && (w.window_class == "#32770")
    end
  end

  # menu action File, New
  def file_new(options={})
    set_focus
    keystroke(VK_MENU, VK_F, VK_N) 
    if message_dialog_confirm 
      options[:save] == true ? keystroke(VK_Y) : keystroke(VK_N)
    end
    # sanity check
    raise "confirm dialog is still here" if message_dialog_confirm 
  end
  
  # menu action File, New
  def file_open(filename, options={})
    set_focus
    keystroke(VK_MENU, VK_F, VK_O) 
    if message_dialog_confirm 
      options[:save] == true ? keystroke(VK_Y) : keystroke(VK_N)
    end

    raise "sanity check, confirm dialog is still here" if message_dialog_confirm 
    raise "sanity check, file_open_dialog not found" unless file_open_dialog

    # Paste in filename for speed, much faster than 'type_in(filename)'
    clipboard.text = filename
    keystroke(VK_CONTROL, VK_V)

    keystroke(VK_RETURN)
  end

  # menu action File, Exit
  def file_exit
    set_focus
    keystroke(VK_N) if message_dialog_confirm 
    keystroke(VK_ESCAPE) if file_open_dialog
    keystroke(VK_MENU, VK_F, VK_X) 
    keystroke(VK_N) if message_dialog_confirm 
  end
  
  # menu action File, Save
  def file_save
    set_focus
    keystroke(VK_MENU, VK_F, VK_S) 
  end
 
  # menu action File, Save As
  def file_save_as(filename, options={})
    set_focus
    keystroke(VK_MENU, VK_F, VK_A) 
    raise "sanity check, file_save_as_dialog not found" unless file_save_as_dialog

    # Paste in filename for speed, much faster than 'type_in(filename)'
    clipboard.text = filename
    keystroke(VK_CONTROL, VK_V)
    keystroke(VK_RETURN)

    if dialog_overwrite_confirm 
      options[:overwrite] == true ? keystroke(VK_Y) : keystroke(VK_N)
    end
    raise "sanity check, overwrite confirm dialog is still here" if dialog_overwrite_confirm 

  end

end
