# a class to run a series of processors in a chain

module Media::Process
  class Chain < Base

    def initialize(source_type, target_type)
      @source_type = source_type
      @target_type = target_type
      Media::Process.may_consume!(@source_type)
      Media::Process.may_produce!(@target_type)
    end

    #
    # what run() is doing:
    #
    # open shared lock on source_file DO
    #   IF able to open exclusive lock on target_file (non-blocking)
    #     then run the processing (note that is call is inside the block
    #     sent to open_write_lock_unblocking and is not a part of the 'if')
    #   ELSE the lock on target_file failed, it means someone is writing to it.
    #      then let them do the work, and just wait for it to be done
    #   END
    # END
    #
    # returns true if the processing all worked, or if the file is currently
    # being written by another thread
    #
    def run(source_file, target_file, thumbdef)
      raise Errno::ENOENT.new(source_file) unless File.exists?(source_file)
      success = false
      open_read_lock(source_file) do
        if open_write_lock_nonblocking(target_file) {
          success = run_on_locked_files(source_file, target_file, thumbdef) }
        else
          open_read_lock(target_file)
          success = true
        end
      end
      return success
    end

    def run_on_locked_files(source_file, target_file, thumbdef)
      input_type = @source_type
      input_file = source_file
      tmp_files = []
      run_at_least_once = false
      begin
        while processor = Media::Process.get_processor_for(input_type)
          if processor.output_to_type?(@target_type)
            # this will be the last run
            output_type = @target_type
            output_file = target_file
          else
            # there will be more processors run
            output_type = processor.output_type
            output_file = processor.tmp_filename_for(output_type)
            tmp_files << output_file
          end

          exists!(input_file)
          processor.run!(:in => input_file, :out => output_file, :size => thumbdef.size)
          exists!(output_file)
          run_at_least_once = true

          if output_type == @target_type
            break
          else
            input_file = output_file
            input_type = output_type
          end
        end
      rescue Exception => exc
        log_error 'ERROR', exc
        return false
      ensure
        tmp_files.each{|f|File.unlink(f) if File.exists?(f)}
      end
      return run_at_least_once
    end

  end # end chain
end # end module
