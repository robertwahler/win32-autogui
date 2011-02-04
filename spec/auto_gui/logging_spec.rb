require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include Autogui::Logging

describe Autogui::Logging do
  before(:all) do
    # quiet console output, we are only testing the file output
    logger.remove(:console)
  end
  before(:each) do
    @logfile = "autogui.log"
    create_file(@logfile, "the quick brown fox")
  end
  after(:each) do
    if @application
      @application.close(:wait_for_close => true) if @application.running?
      @application.should_not be_running
    end
    logger.logfile = nil
  end
  after(:all) do
    logger.add(:console)
  end

  describe "to file" do

    it "should truncate the log on create by default" do
      get_file_contents(@logfile).should == 'the quick brown fox'
      @application = Calculator.new :logger_logfile => fullpath(@logfile)
      get_file_contents(@logfile).should == ''
    end

    it "should not truncate the log on create if 'logger.trunc' is false" do
      get_file_contents(@logfile).should == 'the quick brown fox'
      @application = Calculator.new :logger_logfile => fullpath(@logfile), :logger_trunc => false
      logger.trunc.should be_false
      get_file_contents(@logfile).should == 'the quick brown fox'
    end

    it "should not log unless 'logger.logfile' is set" do
      @application = Calculator.new
      get_file_contents(@logfile).should == 'the quick brown fox'
      logger.warn "warning message 0"
      get_file_contents(@logfile).should == 'the quick brown fox'
      logger.logfile = fullpath(@logfile)
      logger.warn "warning message 1"
      get_file_contents(@logfile).should match(/warning message 1/)
      logger.logfile = nil
      logger.warn "warning message 2"
      get_file_contents(@logfile).should_not match(/warning message 2/)
    end

    it "should log warnings" do
      @application = Calculator.new :logger_logfile => fullpath(@logfile)
      logger.trunc.should be_true
      get_file_contents(@logfile).should == ''
      logger.warn "warning message here"
      get_file_contents(@logfile).should match(/warning message here/)
    end

    it "should log application raised exceptions via 'application.raise_error'" do
      get_file_contents(@logfile).should == 'the quick brown fox'
      begin
        @application = Calculator.new :logger_logfile => fullpath(@logfile), :name => nil
      rescue
      end
      get_file_contents(@logfile).should match(/application name not set/)
    end

    it "should log debug messages when debug level set" do
      @application = Calculator.new :logger_logfile => fullpath(@logfile)
      level_save = logger.level
      begin
        logger.level = Autogui::Logging::WARN
        logger.trunc.should be_true
        get_file_contents(@logfile).should == ''
        logger.debug "debug message here 1"
        get_file_contents(@logfile).should_not match(/debug message here 1/)
        logger.level = Autogui::Logging::DEBUG
        logger.debug "debug message here 2"
        get_file_contents(@logfile).should match(/debug message here 2/)
      ensure
        logger.level = level_save
      end
    end
  end

end
