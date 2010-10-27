# use the development version of win32-autogui
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

end
