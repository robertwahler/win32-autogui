require 'win32/autogui/api'

module Aruba
  module Api
    include Autogui::Api
    
    # returns full path to files in the aruba tmp folder
    def fullpath(filename)
      path = File.expand_path(File.join(current_dir, filename))
      cygpath_to_windows_path(path)
    end

    # return the contents of "filename" in the aruba tmp folder
    def get_file_content(filename)
      in_current_dir do
        IO.read(filename)
      end
    end

  end
end
