require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include Autogui::Logging

describe Autogui::Logging do
  before(:each) do
    FileUtils.rm_rf(current_dir)
    @logfile = "autogui.log"
    create_file(@logfile, "the quick brown fox")
  end
  after(:each) do
    if @application
      @application.close(:wait_for_close => true) if @application.running?
      @application.should_not be_running
    end
  end

  describe "to file" do
    it "should truncate the log on create" do
      get_file_content(@logfile).should == 'the quick brown fox'
      @application = Calculator.new :logger_logfile => fullpath(@logfile)
      get_file_content(@logfile).should == ''
    end

    it "should not log unless 'logger.logfile' is set" do
      @application = Calculator.new 
      get_file_content(@logfile).should == 'the quick brown fox'
      logger.warn "warning message here"
      get_file_content(@logfile).should == 'the quick brown fox'
      logger.logfile = fullpath(@logfile)
      logger.warn "warning message here"
      get_file_content(@logfile).should match(/warning message here/)
    end

    it "should log warnings" do
      @application = Calculator.new :logger_logfile => fullpath(@logfile)
      get_file_content(@logfile).should == ''
      logger.warn "warning message here"
      get_file_content(@logfile).should match(/warning message here/)
    end

    it "should log application raised exceptions via 'application.raise_error'" do
      get_file_content(@logfile).should == 'the quick brown fox'
      begin
        @application = Calculator.new :logger_logfile => fullpath(@logfile), :name => nil
      rescue
        # expected exception
      end
      get_file_content(@logfile).should match(/application name not set/)
    end

    it "should log debug messages when debug level set" do
      @application = Calculator.new :logger_logfile => fullpath(@logfile)
      level_save = logger.level
      begin
        logger.level = Autogui::Logging::WARN
        get_file_content(@logfile).should == ''
        logger.debug "debug message here"
        get_file_content(@logfile).should_not match(/debug message here/)
        logger.level = Autogui::Logging::DEBUG
        logger.debug "debug message here"
        get_file_content(@logfile).should match(/debug message here/)
      ensure
        logger.level = level_save
      end
    end
  end

end
