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

    before(:each) do
      @gemfiles_filename = File.expand_path(File.dirname(__FILE__) + '/../../.gemfiles')
      @gemfiles = File.open(@gemfiles_filename, "r") {|f| f.read}
      @eol = @gemfiles.match("\r\n") ? "\r\n" : "\n"
    end

    def binary?(filename)
      open filename do |f|
        f.each_byte { |x|
          x.nonzero? or return true
        }
      end
      false
    end

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
        next if line =~ /^\s+#.*\s+#{@eol}$/
        failing_lines << number + 1 if line =~ /\s+#{@eol}$/
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
      @gemfiles.split(@eol).each do |filename|
        filename = File.expand_path(File.join(File.dirname(__FILE__), ["..", "..", filename]))
        next if filename =~ /\.gitmodules/
        next if binary?(filename)
        error_messages << check_for_tab_characters(filename)
        error_messages << check_for_extra_spaces(filename)
      end
      error_messages.compact.should be_well_formed
    end

  end
end
