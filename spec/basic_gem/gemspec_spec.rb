require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BasicGem do

  def load_gemspec
    filename = File.expand_path('../../../basic_gem.gemspec', __FILE__)
    eval(File.read(filename), nil, filename)
  end

  describe 'gemspec' do

    it "should return the gem VERSION" do
      @gemspec = load_gemspec
      BasicGem::version.should_not be_nil
      @gemspec.version.to_s.should == BasicGem::version
    end

    describe 'files' do

      it "should return 'files' array" do
        @gemspec = load_gemspec
        @gemspec.files.is_a?(Array).should == true
        @gemspec.files.include?('VERSION').should == true
      end
      it "should return 'executables' array" do
        @gemspec = load_gemspec
        @gemspec.executables.is_a?(Array).should == true
      end

      describe 'without .gemfiles cache' do
        before(:each) do
          File.stub!('exists?').and_return false
          @gemspec = load_gemspec
        end

        it "should return 'files' from using 'git ls-files" do
          File.exists?(File.expand_path('../../../.gemfiles', __FILE__)).should == false
          @gemspec.files.is_a?(Array).should == true
          @gemspec.files.include?('VERSION').should == true
        end
        it "should return 'executables' from 'git ls-files"  do
          File.exists?(File.expand_path('../../../.gemfiles', __FILE__)).should == false
          @gemspec.executables.is_a?(Array).should == true
        end
      end

      describe 'without git binary' do

        before(:each) do
          stub!(:system).and_return false
          @gemspec = load_gemspec
        end

        it "should return 'files' from cache" do
          system('git --version').should == false
          @gemspec.files.is_a?(Array).should == true
          @gemspec.files.include?('VERSION').should == true
        end
        it "should return 'executables' from cache"  do
          system('git --version').should == false
          @gemspec.executables.is_a?(Array).should == true
        end

      end
    end

  end
end
