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

  # menu action File, New
  def file_new(options={})
    set_focus
    keystroke(VK_MENU, VK_F, VK_N) 
    if message_dialog_confirm 
      puts "DEBUG: dialog is here" 
      options[:save] == true ? keystroke(VK_Y) : keystroke(VK_N)
    end
    puts "WARNING: dialog is still here" if message_dialog_confirm 
  end

  # menu action File, Exit
  def file_exit
    set_focus
    keystroke(VK_N) if message_dialog_confirm 
    keystroke(VK_MENU, VK_F, VK_X) 
    keystroke(VK_N) if message_dialog_confirm 
  end

end
