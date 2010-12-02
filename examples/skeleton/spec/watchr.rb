# Watchr: Autotest like functionality
#
# gem install watchr
#
# Run me with:
#
#   $ watchr spec/watchr.rb

require 'term/ansicolor'
require 'rbconfig'

WINDOWS = Config::CONFIG['host_os'] =~ /mswin|mingw/i unless defined?(WINDOWS)
require 'win32/process' if WINDOWS

if WINDOWS
  begin
    require 'Win32/Console/ANSI'
    $c = Term::ANSIColor
  rescue LoadError
    STDERR.puts 'WARNING: You must "gem install win32console" (1.2.0 or higher) to get color output on MRI/Windows'
  end
end

def getch
  state = `stty -g`
  begin
    `stty raw -echo cbreak`
    $stdin.getc
  ensure
    `stty #{state}`
  end
end

# --------------------------------------------------
# Convenience Methods
# --------------------------------------------------
def all_feature_files
  Dir['features/*.feature']
end

def all_spec_files
  files = Dir['spec/**/*_spec\.rb']
end

def run(cmd)

  pid = fork do
    puts "\n"
    if $c
      print $c.cyan, cmd, $c.clear, "\n"
    else
      puts cmd 
    end

    exec(cmd)
  end
  Signal.trap('INT') do
    puts "sending KILL to pid: #{pid}"
    Process.kill("KILL", pid)
  end
  Process.waitpid(pid) if (pid > 0)

  prompt
end

def run_all
  run_all_specs
  run_default_cucumber
end

# allow cucumber rerun.txt smarts
def run_default_cucumber
  cmd = "cucumber"
  run(cmd)
end

def run_all_features
  cmd = "cucumber #{all_feature_files.join(' ')}"
  run(cmd)
end

def run_feature(feature)
  cmd = "cucumber #{feature}"
  $last_feature = feature
  run(cmd)
end

def run_last_feature
  run_feature($last_feature) if $last_feature
end

def run_default_spec
  cmd = "spec _1.3.1_ --color --format s ./spec"
  run(cmd)
end

def run_all_specs
  cmd = "spec _1.3.1_ --color --format s #{all_spec_files.join(' ')}"
  run(cmd)
end

def run_spec(spec)
  cmd = "spec _1.3.1_ --color --format s #{spec}"
  $last_spec = spec
  run(cmd)
end

def run_last_spec
  run_spec($last_spec) if $last_spec
end

def prompt
  menu = "Ctrl-C to quit"
  menu = menu + ", Ctrl-\\ for menu" if Signal.list.include?('QUIT')

  puts menu
end

# init
$last_feature = nil
prompt

# --------------------------------------------------
# Watchr Rules
# --------------------------------------------------
watch( '^features/(.*)\.feature'   )   { run_default_cucumber }

watch( '^bin/(.*)'   )   { run_default_cucumber }
watch( '^lib/(.*)'   )   { run_default_cucumber }

watch( '^features/step_definitions/(.*)\.rb' )   { run_default_cucumber }
watch( '^features/support/(.*)\.rb' )   { run_default_cucumber }

watch( '^spec/(.*)_spec\.rb'   )   { |m| run_spec(m[0]) }
# specify just the lib files that have specs
# TODO: This can be determined automatically from the spec file naming convention
watch( '^lib/(.*)'   )   { run_default_spec }

# --------------------------------------------------
# Signal Handling (May not be supported on Windows)
# --------------------------------------------------
if Signal.list.include?('QUIT')
  # Ctrl-\
  Signal.trap('QUIT') do

    puts "\n\nMENU: a = all , f = features  s = specs, l = last feature (#{$last_feature ? $last_feature : 'none'}), q = quit\n\n"
    c = getch
    puts c.chr
    if c.chr == "a"
      run_all
    elsif c.chr == "f"
      run_default_cucumber
    elsif c.chr == "s"
      run_all_specs
    elsif c.chr == "q"
      abort("exiting\n")
    elsif c.chr == "l"
      run_last_feature
    end

  end
end
