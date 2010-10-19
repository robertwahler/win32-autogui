require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/calculator')

describe AutoGui::Application do

  before do
    @calculator = Calculator.new
  end

  after do
    @calculator.close if @calculator.running?
    sleep 0.5
    @calculator.should_not be_running
  end

  it "should be running when instanciated" do
    @calculator.should be_running
  end

end
