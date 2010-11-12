# NOTE: This module is from the win32-process gem. It has all the incomplete
# wait methods removed.
#
# http://github.com/djberg96/win32-process
#
# TODO: remove this module and use the win32-process gem once the wait issues have
# been resolved.
#
require 'windows/error'
require 'windows/process'
require 'windows/thread'
require 'windows/synchronize'
require 'windows/handle'
require 'windows/library'
require 'windows/console'
require 'windows/window'
require 'windows/unicode'
require 'windows/tool_helper'
require 'windows/security'
require 'windows/msvcrt/string'

module Process
  # The Process::Error class is typically raised if any of the custom
  # Process methods fail.
  class Error < RuntimeError; end

  # Eliminates redefinition warnings.
  undef_method :getpriority, :kill, :getrlimit, :ppid, :setrlimit
  undef_method :setpriority, :uid
   
  include Windows::Process
  include Windows::Thread
  include Windows::Error
  include Windows::Library
  include Windows::Console
  include Windows::Handle
  include Windows::Security
  include Windows::Synchronize
  include Windows::Window
  include Windows::Unicode
  include Windows::ToolHelper
  include Windows::MSVCRT::String

  extend Windows::Error
  extend Windows::Process
  extend Windows::Thread
  extend Windows::Security
  extend Windows::Synchronize
  extend Windows::Handle
  extend Windows::Library
  extend Windows::Console
  extend Windows::Unicode
  extend Windows::ToolHelper
  extend Windows::MSVCRT::String
   
  # :stopdoc:
   
  # Used by Process.create
  ProcessInfo = Struct.new("ProcessInfo",
    :process_handle,
    :thread_handle,
    :process_id,
    :thread_id
  )
   
  @child_pids = []  # Static variable used for Process.fork
  @i = -1           # Static variable used for Process.fork

  # These are probably not defined on MS Windows by default
  unless defined? RLIMIT_CPU
    RLIMIT_CPU    = 0 # PerProcessUserTimeLimit
    RLIMIT_FSIZE  = 1 # Hard coded at 4TB - 64K (assumes NTFS)
    RLIMIT_AS     = 5 # ProcessMemoryLimit
    RLIMIT_RSS    = 5 # ProcessMemoryLimit
    RLIMIT_VMEM   = 5 # ProcessMemoryLimit
  end
   
  # :startdoc:

  # Returns the process and system affinity mask for the given +pid+, or the
  # current process if no pid is provided. The return value is a two element
  # array, with the first containing the process affinity mask, and the second
  # containing the system affinity mask. Both are decimal values.
  #
  # A process affinity mask is a bit vector indicating the processors that a
  # process is allowed to run on. A system affinity mask is a bit vector in
  # which each bit represents the processors that are configured into a
  # system.
  #
  # Example:
  #
  #    # System has 4 processors, current process is allowed to run on all
  #    Process.get_affinity # => [[15], [15]]
  #
  #    # System has 4 processors, current process only allowed on 1 and 4 only
  #    Process.get_affinity # => [[9], [15]]
  #
  # If you want to convert a decimal bit vector into an array of 0's and 1's
  # indicating the flag value of each processor, you can use something like
  # this approach:
  #
  #    mask = Process.get_affinity.first
  #    (0..mask).to_a.map{ |n| mask[n] }
  #
  def get_affinity(int = Process.pid)
    pmask = 0.chr * 4
    smask = 0.chr * 4

    if int == Process.pid
      unless GetProcessAffinityMask(GetCurrentProcess(), pmask, smask)
        raise Error, get_last_error
      end
    else
      begin
        handle = OpenProcess(PROCESS_QUERY_INFORMATION, 0 , int)

        if handle == INVALID_HANDLE_VALUE
          raise Error, get_last_error
        end

        unless GetProcessAffinityMask(handle, pmask, smask)
          raise Error, get_last_error
        end
      ensure
        CloseHandle(handle) if handle != INVALID_HANDLE_VALUE
      end
    end

    pmask = pmask.unpack('L').first
    smask = smask.unpack('L').first

    [pmask, smask]
  end

  # Returns whether or not the current process is part of a Job.
  #
  def job?
    pbool = 0.chr * 4
    IsProcessInJob(GetCurrentProcess(), nil, pbool)
    pbool.unpack('L').first == 0 ? false : true
  end

  # Gets the resource limit of the current process. Only a limited number
  # of flags are supported.
  #
  # Process::RLIMIT_CPU
  # Process::RLIMIT_FSIZE
  # Process::RLIMIT_AS
  # Process::RLIMIT_RSS
  # Process::RLIMIT_VMEM
  #
  # The Process:RLIMIT_AS, Process::RLIMIT_RSS and Process::VMEM constants
  # all refer to the Process memory limit. The Process::RLIMIT_CPU constant
  # refers to the per process user time limit. The Process::RLIMIT_FSIZE
  # constant is hard coded to the maximum file size on an NTFS filesystem,
  # approximately 4TB (or 4GB if not NTFS).
  #
  # While a two element array is returned in order to comply with the spec,
  # there is no separate hard and soft limit. The values will always be the
  # same.
  #
  # If [0,0] is returned then it means no limit has been set.
  #
  # Example:
  #
  #   Process.getrlimit(Process::RLIMIT_VMEM) # => [0, 0]
  #--
  # NOTE: Both the getrlimit and setrlimit method use an at_exit handler
  # to close a job handle. This is necessary because simply calling it
  # at the end of the block, while marking it for closure, would also make
  # it unavailable even within the same process since it would no longer
  # be associated with the job.
  #
  def getrlimit(resource)
    if resource == RLIMIT_FSIZE
      if get_volume_type == 'NTFS'
        return ((1024**4) * 4) - (1024 * 64) # ~4 TB
      else
        return (1024**3) * 4 # 4 GB
      end
    end

    handle = nil
    in_job = Process.job?

    # Put the current process in a job if it's not already in one
    if in_job && defined?(@job_name)
      handle = OpenJobObject(JOB_OBJECT_QUERY, true, @job_name)
      raise Error, get_last_error if handle == 0
    else
      @job_name = 'ruby_' + Process.pid.to_s
      handle = CreateJobObject(nil, @job_name)
      raise Error, get_last_error if handle == 0
    end

    begin
      unless in_job
        unless AssignProcessToJobObject(handle, GetCurrentProcess())
          raise Error, get_last_error
        end
      end

      buf = 0.chr * 112 # sizeof(struct JOBJECT_EXTENDED_LIMIT_INFORMATION)
      val = nil         # value returned at end of method

      # Set the LimitFlags member of the struct
      case resource
        when RLIMIT_CPU
          buf[16,4] = [JOB_OBJECT_LIMIT_PROCESS_TIME].pack('L')
        when RLIMIT_AS, RLIMIT_VMEM, RLIMIT_RSS
          buf[16,4] = [JOB_OBJECT_LIMIT_PROCESS_MEMORY].pack('L')
        else
          raise Error, "unsupported resource type"
      end

      bool = QueryInformationJobObject(
        handle,
        JobObjectExtendedLimitInformation,
        buf,
        buf.size,
        nil
      )

      unless bool
        raise Error, get_last_error
      end

      case resource
        when Process::RLIMIT_CPU
          val = buf[0,8].unpack('Q').first
        when RLIMIT_AS, RLIMIT_VMEM, RLIMIT_RSS
          val = buf[96,4].unpack('L').first
      end
    ensure
      at_exit{ CloseHandle(handle) if handle }
    end

    [val, val] # Return an array of two values to comply with spec
  end

  # Sets the resource limit of the current process. Only a limited number
  # of flags are supported.
  #
  # Process::RLIMIT_CPU
  # Process::RLIMIT_AS
  # Process::RLIMIT_RSS
  # Process::RLIMIT_VMEM
  #
  # The Process:RLIMIT_AS, Process::RLIMIT_RSS and Process::VMEM constants
  # all refer to the Process memory limit. The Process::RLIMIT_CPU constant
  # refers to the per process user time limit.
  #
  # The +max_limit+ parameter is provided for interface compatibility only.
  # It is always set to the current_limit value.
  #
  # Example:
  #
  #   Process.setrlimit(Process::RLIMIT_VMEM, 1024 * 4) # => nil
  #   Process.getrlimit(Process::RLIMIT_VMEM) # => [4096, 4096]
  #
  def setrlimit(resource, current_limit, max_limit = nil)
    max_limit = current_limit

    handle = nil
    in_job = Process.job?

    # Put the current process in a job if it's not already in one
    if in_job && defined? @job_name
      handle = OpenJobObject(JOB_OBJECT_SET_ATTRIBUTES, true, @job_name)
      raise Error, get_last_error if handle == 0
    else
      @job_name = 'ruby_' + Process.pid.to_s
      handle = CreateJobObject(nil, job_name)
      raise Error, get_last_error if handle == 0
    end

    begin
      unless in_job
        unless AssignProcessToJobObject(handle, GetCurrentProcess())
          raise Error, get_last_error
        end
      end

      # sizeof(struct JOBJECT_EXTENDED_LIMIT_INFORMATION)
      buf = 0.chr * 112

      # Set the LimitFlags and relevant members of the struct
      case resource
        when RLIMIT_CPU
          buf[16,4] = [JOB_OBJECT_LIMIT_PROCESS_TIME].pack('L')
          buf[0,8]  = [max_limit].pack('Q') # PerProcessUserTimeLimit
        when RLIMIT_AS, RLIMIT_VMEM, RLIMIT_RSS
          buf[16,4] = [JOB_OBJECT_LIMIT_PROCESS_MEMORY].pack('L')
          buf[96,4] = [max_limit].pack('L') # ProcessMemoryLimit
        else
          raise Error, "unsupported resource type"
      end

      bool = SetInformationJobObject(
        handle,
        JobObjectExtendedLimitInformation,
        buf,
        buf.size
      )

      unless bool
        raise Error, get_last_error
      end
    ensure
      at_exit{ CloseHandle(handle) if handle }
    end
  end

  # Retrieves the priority class for the specified process id +int+. Unlike
  # the default implementation, lower values do not necessarily correspond to
  # higher priority classes.
  #
  # The +kind+ parameter is ignored but present for API compatibility.
  # You can only retrieve process information, not process group or user
  # information, so it is effectively always Process::PRIO_PROCESS.
  #
  # Possible return values are:
  #
  # 32    - Process::NORMAL_PRIORITY_CLASS
  # 64    - Process::IDLE_PRIORITY_CLASS
  # 128   - Process::HIGH_PRIORITY_CLASS
  # 256   - Process::REALTIME_PRIORITY_CLASS
  # 16384 - Process::BELOW_NORMAL_PRIORITY_CLASS
  # 32768 - Process::ABOVE_NORMAL_PRIORITY_CLASS
  # 
  def getpriority(kind = Process::PRIO_PROCESS, int = nil)
    raise ArgumentError unless int

    handle = OpenProcess(PROCESS_QUERY_INFORMATION, 0 , int)

    if handle == INVALID_HANDLE_VALUE
      raise Error, get_last_error
    end

    priority_class = GetPriorityClass(handle)

    if priority_class == 0
      raise Error, get_last_error
    end

    priority_class
  end

  # Sets the priority class for the specified process id +int+.
  #
  # The +kind+ parameter is ignored but present for API compatibility.
  # You can only retrieve process information, not process group or user
  # information, so it is effectively always Process::PRIO_PROCESS.
  #
  # Possible +int_priority+ values are:
  #
  # * Process::NORMAL_PRIORITY_CLASS
  # * Process::IDLE_PRIORITY_CLASS
  # * Process::HIGH_PRIORITY_CLASS
  # * Process::REALTIME_PRIORITY_CLASS
  # * Process::BELOW_NORMAL_PRIORITY_CLASS
  # * Process::ABOVE_NORMAL_PRIORITY_CLASS
  #
  def setpriority(kind = nil, int = nil, int_priority = nil)
    raise ArgumentError unless int
    raise ArgumentError unless int_priority

    handle = OpenProcess(PROCESS_SET_INFORMATION, 0 , int)

    if handle == INVALID_HANDLE_VALUE
      raise Error, get_last_error
    end

    unless SetPriorityClass(handle, int_priority)
      raise Error, get_last_error
    end

    return 0 # Match the spec
  end

  # Returns the uid of the current process. Specifically, it returns the
  # RID of the SID associated with the owner of the process.
  #
  # If +sid+ is set to true, then a binary sid is returned. Otherwise, a
  # numeric id is returned (the default).
  #--
  # The Process.uid method in core Ruby always returns 0 on MS Windows.
  #
  def uid(sid = false)
    token = 0.chr * 4

    unless OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, token)
      raise Error, get_last_error
    end

    token   = token.unpack('V')[0]
    rlength = 0.chr * 4
    tuser   = 0.chr * 512

    bool = GetTokenInformation(
      token,
      TokenUser,
      tuser,
      tuser.size,
      rlength
    )

    unless bool
      raise Error, get_last_error
    end

    lsid = tuser[8, (rlength.unpack('L').first - 8)]

    if sid
      lsid
    else
      sid_addr = [lsid].pack('p*').unpack('L')[0]
      sid_buf  = 0.chr * 80
      sid_ptr  = 0.chr * 4

      unless ConvertSidToStringSid(sid_addr, sid_ptr)
        raise Error, get_last_error
      end

      strcpy(sid_buf, sid_ptr.unpack('L')[0])
      sid_buf.strip.split('-').last.to_i
    end
  end 

   
  # Sends the given +signal+ to an array of process id's. The +signal+ may
  # be any value from 0 to 9, or the special strings 'SIGINT' (or 'INT'),
  # 'SIGBRK' (or 'BRK') and 'SIGKILL' (or 'KILL'). An array of successfully
  # killed pids is returned.
  # 
  # Signal 0 merely tests if the process is running without killing it.
  # Signal 2 sends a CTRL_C_EVENT to the process.
  # Signal 3 sends a CTRL_BRK_EVENT to the process.
  # Signal 9 kills the process in a harsh manner.
  # Signals 1 and 4-8 kill the process in a nice manner.
  # 
  # SIGINT/INT corresponds to signal 2
  # SIGBRK/BRK corresponds to signal 3
  # SIGKILL/KILL corresponds to signal 9
  # 
  # Signals 2 and 3 only affect console processes, and then only if the
  # process was created with the CREATE_NEW_PROCESS_GROUP flag.
  # 
  def kill(signal, *pids)
    case signal
      when 'SIGINT', 'INT'
        signal = 2
      when 'SIGBRK', 'BRK'
        signal = 3
      when 'SIGKILL', 'KILL'
        signal = 9
      when 0..9
        # Do nothing
      else
        raise Error, "Invalid signal '#{signal}'"
    end
      
    killed_pids = []
      
    pids.each{ |pid|
      # Send the signal to the current process if the pid is zero
      if pid == 0
        pid = Process.pid
      end
       
      # No need for full access if the signal is zero
      if signal == 0
        access = PROCESS_QUERY_INFORMATION | PROCESS_VM_READ
        handle = OpenProcess(access, 0 , pid)
      else
        handle = OpenProcess(PROCESS_ALL_ACCESS, 0, pid)
      end
         
      begin
        case signal
          when 0   
            if handle != 0
              killed_pids.push(pid)
            else
              # If ERROR_ACCESS_DENIED is returned, we know it's running
              if GetLastError() == ERROR_ACCESS_DENIED
                killed_pids.push(pid)
              else
                raise Error, get_last_error
              end
            end
          when 2
            if GenerateConsoleCtrlEvent(CTRL_C_EVENT, pid)
              killed_pids.push(pid)
            end
          when 3
            if GenerateConsoleCtrlEvent(CTRL_BREAK_EVENT, pid)
              killed_pids.push(pid)
            end
          when 9
            if TerminateProcess(handle, pid)
              killed_pids.push(pid)
              @child_pids.delete(pid)           
            else
              raise Error, get_last_error
            end
          else
            if handle != 0
              thread_id = [0].pack('L')
              begin 
                thread = CreateRemoteThread(
                  handle,
                  0,
                  0,
                  GetProcAddress(GetModuleHandle('kernel32'), 'ExitProcess'),
                  0,
                  0,
                  thread_id
                )

                if thread
                  WaitForSingleObject(thread, 5)
                  killed_pids.push(pid)
                  @child_pids.delete(pid)
                else
                  raise Error, get_last_error
                end
              ensure
                CloseHandle(thread) if thread
              end
            else
              raise Error, get_last_error
          end # case

          @child_pids.delete(pid)
        end
      ensure
        CloseHandle(handle) unless handle == INVALID_HANDLE_VALUE
      end
    }
      
    killed_pids
  end
   
  # Process.create(key => value, ...) => ProcessInfo
  # 
  # This is a wrapper for the CreateProcess() function. It executes a process,
  # returning a ProcessInfo struct. It accepts a hash as an argument.
  # There are several primary keys:
	#
  # * command_line     (mandatory)
  # * app_name         (default: nil)
  # * inherit          (default: false)
  # * process_inherit  (default: false)
  # * thread_inherit   (default: false)
  # * creation_flags   (default: 0)
  # * cwd              (default: Dir.pwd)
  # * startup_info     (default: nil)
  # * environment      (default: nil)
  # * close_handles    (default: true)
  # * with_logon       (default: nil)
  # * domain           (default: nil)
  # * password         (default: nil)
	#
  # Of these, the 'command_line' or 'app_name' must be specified or an
  # error is raised. Both may be set individually, but 'command_line' should
  # be preferred if only one of them is set because it does not (necessarily)
  # require an explicit path or extension to work.
  #
  # The 'domain' and 'password' options are only relevent in the context
  # of 'with_logon'.
	#
  # The startup_info key takes a hash. Its keys are attributes that are
  # part of the StartupInfo struct, and are generally only meaningful for
  # GUI or console processes. See the documentation on CreateProcess()
  # and the StartupInfo struct on MSDN for more information.
	# 	
  # * desktop
  # * title
  # * x
  # * y
  # * x_size
  # * y_size
  # * x_count_chars
  # * y_count_chars
  # * fill_attribute
  # * sw_flags
  # * startf_flags
  # * stdin
  # * stdout
  # * stderr
  # 
  # The relevant constants for 'creation_flags', 'sw_flags' and 'startf_flags'
  # are included in the Windows::Process, Windows::Console and Windows::Window
  # modules. These come with the windows-pr library, a prerequisite of this
  # library. Note that the 'stdin', 'stdout' and 'stderr' options can be
  # either Ruby IO objects or file descriptors (i.e. a fileno). However,
  # StringIO objects are not currently supported.
  #
  # If 'stdin', 'stdout' or 'stderr' are specified, then the +inherit+ value
  # is automatically set to true and the Process::STARTF_USESTDHANDLES flag is
  # automatically OR'd to the +startf_flags+ value.
  # 
  # The ProcessInfo struct contains the following members:
  # 
  # * process_handle - The handle to the newly created process.
  # * thread_handle  - The handle to the primary thread of the process.
  # * process_id     - Process ID.
  # * thread_id      - Thread ID.
  #
  # If the 'close_handles' option is set to true (the default) then the
  # process_handle and the thread_handle are automatically closed for you
  # before the ProcessInfo struct is returned.
  #
  # If the 'with_logon' option is set, then the process runs the specified
  # executable file in the security context of the specified credentials.
  #
  def create(args)
    unless args.kind_of?(Hash)
      raise TypeError, 'Expecting hash-style keyword arguments'
    end
      
    valid_keys = %w/
      app_name command_line inherit creation_flags cwd environment
      startup_info thread_inherit process_inherit close_handles with_logon
      domain password
    /

    valid_si_keys = %/
      startf_flags desktop title x y x_size y_size x_count_chars
      y_count_chars fill_attribute sw_flags stdin stdout stderr
    /

    # Set default values
    hash = {
      'app_name'       => nil,
      'creation_flags' => 0,
      'close_handles'  => true
    }
      
    # Validate the keys, and convert symbols and case to lowercase strings.     
    args.each{ |key, val|
      key = key.to_s.downcase
      unless valid_keys.include?(key)
        raise Error, "invalid key '#{key}'"
      end
      hash[key] = val
    }
      
    si_hash = {}
      
    # If the startup_info key is present, validate its subkeys
    if hash['startup_info']
      hash['startup_info'].each{ |key, val|
        key = key.to_s.downcase
        unless valid_si_keys.include?(key)
          raise Error, "invalid startup_info key '#{key}'"
        end
        si_hash[key] = val
      }
    end
      
    # The +command_line+ key is mandatory unless the +app_name+ key
    # is specified.
    unless hash['command_line']
      if hash['app_name']
        hash['command_line'] = hash['app_name']
        hash['app_name'] = nil
      else
        raise Error, 'command_line or app_name must be specified'
      end
    end
      
    # The environment string should be passed as a string of ';' separated
    # paths.
    if hash['environment'] 
      env = hash['environment'].split(File::PATH_SEPARATOR) << 0.chr
      if hash['with_logon']
        env = env.map{ |e| multi_to_wide(e) }
        env = [env.join("\0\0")].pack('p*').unpack('L').first            
      else
        env = [env.join("\0")].pack('p*').unpack('L').first
      end
    else
      env = nil
    end

    startinfo = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    startinfo = startinfo.pack('LLLLLLLLLLLLSSLLLL')
    procinfo  = [0,0,0,0].pack('LLLL')

    # Process SECURITY_ATTRIBUTE structure
    process_security = 0
    if hash['process_inherit']
      process_security = [0,0,0].pack('LLL')
      process_security[0,4] = [12].pack('L') # sizeof(SECURITY_ATTRIBUTE)
      process_security[8,4] = [1].pack('L')  # TRUE
    end

    # Thread SECURITY_ATTRIBUTE structure
    thread_security = 0
    if hash['thread_inherit']
      thread_security = [0,0,0].pack('LLL')
      thread_security[0,4] = [12].pack('L') # sizeof(SECURITY_ATTRIBUTE)
      thread_security[8,4] = [1].pack('L')  # TRUE
    end

    # Automatically handle stdin, stdout and stderr as either IO objects
    # or file descriptors.  This won't work for StringIO, however.
    ['stdin', 'stdout', 'stderr'].each{ |io|
      if si_hash[io]
        if si_hash[io].respond_to?(:fileno)
          handle = get_osfhandle(si_hash[io].fileno)
        else
          handle = get_osfhandle(si_hash[io])
        end
            
        if handle == INVALID_HANDLE_VALUE
          raise Error, get_last_error
        end

        # Most implementations of Ruby on Windows create inheritable
        # handles by default, but some do not. RF bug #26988.
        bool = SetHandleInformation(
          handle,
          HANDLE_FLAG_INHERIT,
          HANDLE_FLAG_INHERIT
        )

        raise Error, get_last_error unless bool
            
        si_hash[io] = handle
        si_hash['startf_flags'] ||= 0
        si_hash['startf_flags'] |= STARTF_USESTDHANDLES
        hash['inherit'] = true
      end
    }
      
    # The bytes not covered here are reserved (null)
    unless si_hash.empty?
      startinfo[0,4]  = [startinfo.size].pack('L')
      startinfo[8,4]  = [si_hash['desktop']].pack('p*') if si_hash['desktop']
      startinfo[12,4] = [si_hash['title']].pack('p*') if si_hash['title']
      startinfo[16,4] = [si_hash['x']].pack('L') if si_hash['x']
      startinfo[20,4] = [si_hash['y']].pack('L') if si_hash['y']
      startinfo[24,4] = [si_hash['x_size']].pack('L') if si_hash['x_size']
      startinfo[28,4] = [si_hash['y_size']].pack('L') if si_hash['y_size']
      startinfo[32,4] = [si_hash['x_count_chars']].pack('L') if si_hash['x_count_chars']
      startinfo[36,4] = [si_hash['y_count_chars']].pack('L') if si_hash['y_count_chars']
      startinfo[40,4] = [si_hash['fill_attribute']].pack('L') if si_hash['fill_attribute']
      startinfo[44,4] = [si_hash['startf_flags']].pack('L') if si_hash['startf_flags']
      startinfo[48,2] = [si_hash['sw_flags']].pack('S') if si_hash['sw_flags']
      startinfo[56,4] = [si_hash['stdin']].pack('L') if si_hash['stdin']
      startinfo[60,4] = [si_hash['stdout']].pack('L') if si_hash['stdout']
      startinfo[64,4] = [si_hash['stderr']].pack('L') if si_hash['stderr']        
    end

    if hash['with_logon']
      logon  = multi_to_wide(hash['with_logon'])
      domain = multi_to_wide(hash['domain'])
      app    = hash['app_name'].nil? ? nil : multi_to_wide(hash['app_name'])
      cmd    = hash['command_line'].nil? ? nil : multi_to_wide(hash['command_line'])
      cwd    = multi_to_wide(hash['cwd'])
      passwd = multi_to_wide(hash['password'])
         
      hash['creation_flags'] |= CREATE_UNICODE_ENVIRONMENT

      bool = CreateProcessWithLogonW(
        logon,                  # User
        domain,                 # Domain
        passwd,                 # Password
        LOGON_WITH_PROFILE,     # Logon flags
        app,                    # App name
        cmd,                    # Command line
        hash['creation_flags'], # Creation flags
        env,                    # Environment
        cwd,                    # Working directory
        startinfo,              # Startup Info
        procinfo                # Process Info
      )
    else     
      bool = CreateProcess(
        hash['app_name'],       # App name
        hash['command_line'],   # Command line
        process_security,       # Process attributes
        thread_security,        # Thread attributes
        hash['inherit'],        # Inherit handles?
        hash['creation_flags'], # Creation flags
        env,                    # Environment
        hash['cwd'],            # Working directory
        startinfo,              # Startup Info
        procinfo                # Process Info
      )
    end      
      
    # TODO: Close stdin, stdout and stderr handles in the si_hash unless
    # they're pointing to one of the standard handles already. [Maybe]
    unless bool
      raise Error, "CreateProcess() failed: ", get_last_error
    end
      
    # Automatically close the process and thread handles in the
    # PROCESS_INFORMATION struct unless explicitly told not to.
    if hash['close_handles']
      CloseHandle(procinfo[0,4].unpack('L').first)
      CloseHandle(procinfo[4,4].unpack('L').first)
    end      
      
    ProcessInfo.new(
      procinfo[0,4].unpack('L').first, # hProcess
      procinfo[4,4].unpack('L').first, # hThread
      procinfo[8,4].unpack('L').first, # hProcessId
      procinfo[12,4].unpack('L').first # hThreadId
    )
  end
   

  # Returns the process ID of the parent of this process.
  #--
  # In MRI this method always returns 0.
  #
  def ppid
    ppid = 0

    return ppid if Process.pid == 0 # Paranoia

    handle = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)

    if handle == INVALID_HANDLE_VALUE
      raise Error, get_last_error
    end

    proc_entry = 0.chr * 296 # 36 + 260
    proc_entry[0, 4] = [proc_entry.size].pack('L') # Set dwSize member
      
    begin             
      unless Process32First(handle, proc_entry)
        error = get_last_error
        raise Error, error
      end

      while Process32Next(handle, proc_entry)
        if proc_entry[8, 4].unpack('L')[0] == Process.pid
          ppid = proc_entry[24, 4].unpack('L')[0] # th32ParentProcessID
          break
        end
      end
    ensure
      CloseHandle(handle)
    end

    ppid
  end

  # Creates the equivalent of a subshell via the CreateProcess() function.
  # This behaves in a manner that is similar, but not identical to, the
  # Kernel.fork method for Unix. Unlike the Unix fork, this method starts
  # from the top of the script rather than the point of the call.
  #
  # WARNING: This implementation should be considered experimental. It is
  # not recommended for production use.
  # 
  def fork
    last_arg = ARGV.last
      
    # Look for the 'child#xxx' tag
    if last_arg =~ /child#\d+/
      @i += 1
      num = last_arg.split('#').last.to_i
      if num == @i
        if block_given?
          status = 0
          begin
            yield
          rescue Exception
            status = -1 # Any non-zero result is failure
          ensure
            return status
          end
        end
        return nil
      else
        return false
      end
    end
   
    # Tag the command with the word 'child#xxx' to distinguish it
    # from the calling process.
    cmd = 'ruby -I "' + $LOAD_PATH.join(File::PATH_SEPARATOR) << '" "'
    cmd << File.expand_path($PROGRAM_NAME) << '" ' << ARGV.join(' ')
    cmd << ' child#' << @child_pids.length.to_s
      
    startinfo = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    startinfo = startinfo.pack('LLLLLLLLLLLLSSLLLL')
    procinfo  = [0,0,0,0].pack('LLLL')
      
    rv = CreateProcess(0, cmd, 0, 0, 1, 0, 0, 0, startinfo, procinfo)
      
    if rv == 0
      raise Error, get_last_error
    end
      
    pid = procinfo[8,4].unpack('L').first
    @child_pids.push(pid)
      
    pid 
  end
   
  module_function :create, :fork, :get_affinity, :getrlimit, :getpriority
  module_function :job?, :kill, :ppid, :setpriority, :setrlimit
  module_function :uid
end

# Create a global fork method
module Kernel
  undef_method :fork # Eliminate redefinition warning
  def fork(&block)
    Process.fork(&block)
  end
end
