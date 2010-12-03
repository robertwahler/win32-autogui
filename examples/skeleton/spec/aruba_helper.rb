module Aruba
  module Api

    # @return full path to files in the aruba tmp folder
    def fullpath(filename)
      path = File.expand_path(File.join(current_dir, filename))
      if path.match(/^\/cygdrive/)
        # match /cygdrive/c/path/to and return c:\\path\\to
        path = `cygpath -w #{path}`.chomp
      elsif path.match(/.\:/)
        # match c:/path/to and return c:\\path\\to
        path = path.gsub(/\//, '\\')
      end
      path
    end

    # @return the contents of "filename" in the aruba tmp folder
    def get_file_contents(filename)
      in_current_dir do
        IO.read(filename)
      end
    end

  end
end
