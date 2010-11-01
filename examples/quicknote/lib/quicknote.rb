# use the development version of win32-autogui
# Production code should simply require 'win32/autogui'
require File.expand_path(File.dirname(__FILE__) + '/../../../lib/win32/autogui')

class Quicknote < Autogui::Application

  # TODO: replace hard-coded path
  def initialize(name="\\dat\\win32-autogui\\examples\\quicknote\\exe\\quicknote", options = {:title=> "QuickNote -"})
    super name, options
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

  def message_dialog_confirm
    Autogui::EnumerateDesktopWindows.new.find do |w| 
      w.title.match(/Confirm/) && (w.pid == pid)
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
      #puts "DEBUG: confirm dialog is here" 
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
      #puts "DEBUG: confirm dialog is here" 
      options[:save] == true ? keystroke(VK_Y) : keystroke(VK_N)
    end

    # sanity checks
    raise "confirm dialog is still here" if message_dialog_confirm 
    raise "file_open_dialog not found" unless file_open_dialog

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

end
