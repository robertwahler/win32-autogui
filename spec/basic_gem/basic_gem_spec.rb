require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AutoGui do
  
  describe 'version' do

    it "should return a string formatted '#.#.#'" do
      AutoGui::version.should match(/(^[\d]+\.[\d]+\.[\d]+$)/)
    end

  end

end
