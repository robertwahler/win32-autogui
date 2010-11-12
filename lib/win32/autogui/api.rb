module Autogui
  module Api

    # cygwin paths to dos style
    def cygpath_to_windows_path(path)
      path = `cygpath -w #{path}`.chomp if path.match(/^\/cygdrive/)
      path
    end

  end
end
