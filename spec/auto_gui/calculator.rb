require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class Calculator < AutoGui::Application

  def initialize(name="calc", options = {:title=> "Calculator"})
    super name, options
  end

end
