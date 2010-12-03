# Reopen module and supply missing constants and
# functions from windows-pr gem
#
# TODO: Fork and send pull request for Windows::Window module, be sure to lock bundle before sending request
#
module Windows
  module Window

    SC_CLOSE = 0xF060

    API.auto_namespace = 'Windows::Window'
    API.auto_constant  = true
    API.auto_method    = true
    API.auto_unicode   = false

    API.new('IsWindow', 'L', 'I', 'user32')
    API.new('SetForegroundWindow', 'L', 'I', 'user32')
    API.new('SendMessageA', 'LIIP', 'I', 'user32')

  end
end
