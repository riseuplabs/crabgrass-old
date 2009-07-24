
module Media::Process
  class Base

    cattr_accessor :log_to_stdout_when

    def cmd(*args)
      cmdstr = args.collect{|arg| arg.shell_escape}.join(' ')
      log cmdstr
      if log_to_stdout_when == :never
        output = `#{cmdstr} 2>/dev/null`
      else
        output = `#{cmdstr}`
      end
      return [$?.success?, output]
    end

    def log(*args)
      ActiveRecord::Base.logger.info "Media::Process --- " + args.join(' ')
      puts args.join(' ') if log_to_stdout_when == :always
    end

    def log_error(*args)
      log(*args)
      puts args.join(' ') if log_to_stdout_when == :on_error
    end

    def exists!(file)
       raise Errno::ENOENT.new(file) unless File.exists?(file)
    end

    # returns:
    # 0     : lock was successfully acquired, yield was run.
    # false : couldn't get non-blocking block, and yield was not run. (only if mode is non-blocking).
    def flock(file, mode)
      success = file.flock(mode)
      if success
        begin
          yield
        ensure
          file.flock(File::LOCK_UN)
        end
      end
      return success
    end

    def open_lock(filename, openmode="r", lockmode=nil)
      success = false
      if openmode == 'r' || openmode == 'rb'
        lockmode ||= File::LOCK_SH
      else
        lockmode ||= File::LOCK_EX
      end
      open(filename, openmode) do |f|
        success = flock(f, lockmode) do
          yield
        end
      end
      return success
  end

    def open_read_lock(filename, &block)
      open_lock(filename,'r', &block)
    end

    def open_write_lock_nonblocking(filename, &block)
      open_lock(filename,'w',File::LOCK_EX|File::LOCK_NB, &block)
    end

  end # base
end # module
