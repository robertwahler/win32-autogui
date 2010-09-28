require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BasicGem do
  
  describe 'VERSION' do

    it "should return a string formatted '#.#.#'" do
      BasicGem::VERSION.should match(/(^[\d]+\.[\d]+\.[\d]+$)/)
    end

  end

end
