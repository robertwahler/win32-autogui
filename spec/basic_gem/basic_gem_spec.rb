require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Autogui do

  describe 'version' do

    it "should return a string formatted '#.#.#'" do
      Autogui::version.should match(/(^[\d]+\.[\d]+\.[\d]+$)/)
    end

  end

  # VIM autocmd to remove trailing whitespace
  # autocmd BufWritePre * :%s/\s\+$//e
  #
  describe "code" do

    def check_for_tab_characters(filename)
      failing_lines = []
      File.readlines(filename).each_with_index do |line,number|
        failing_lines << number + 1 if line =~ /\t/
      end

      unless failing_lines.empty?
        "#{filename} has tab characters on lines #{failing_lines.join(', ')}"
      end
    end

    def check_for_extra_spaces(filename)
      failing_lines = []
      File.readlines(filename).each_with_index do |line,number|
        next if line =~ /^\s+#.*\s+\n$/
        failing_lines << number + 1 if line =~ /\s+\n$/
      end

      unless failing_lines.empty?
        "#{filename} has spaces on the EOL on lines #{failing_lines.join(', ')}"
      end
    end

    Spec::Matchers.define :be_well_formed do
      failure_message_for_should do |actual|
        actual.join("\n")
      end

      match do |actual|
        actual.empty?
      end
    end

    it "has no malformed whitespace" do
      error_messages = []
      gemfiles_filename = File.expand_path(File.dirname(__FILE__) + '/../../.gemfiles')
      files = File.open(gemfiles_filename, "r") {|f| f.read}
      files.split("\n").each do |filename|
        error_messages << check_for_tab_characters(filename)
        error_messages << check_for_extra_spaces(filename)
      end
      error_messages.compact.should be_well_formed
    end

  end
end
