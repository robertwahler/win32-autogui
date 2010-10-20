require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class Calculator < AutoGui::Application

  def initialize(name="calc", options = {:title=> "Calculator"})
    super name, options
  end

  def edit_window
    main_window.children.find {|w| w.window_class == 'Edit'}
  end

end
