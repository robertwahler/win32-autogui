require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BasicGem do
  
  before(:each) do
    @filename = 'input.txt'
    create_file(@filename, "the quick brown fox")
  end

  describe 'Aruba::API.current_dir' do

    it "should return the current dir as 'tmp/aruba'" do
      current_dir.should match(/^tmp\/aruba$/)
    end
  end

  describe "aruba_helper fullpath('input.txt')" do

    it "should return a valid expanded path to 'input.txt'" do
      path = fullpath('input.txt')
      path.should match(/tmp..*aruba/)
      File.exists?(path).should == true
    end
  end

  describe "aruba_helper get_file_contents('input.txt')" do

    it "should return the contents of 'input.txt' as a String" do
      get_file_contents('input.txt').should == 'the quick brown fox'
    end
  end

end
