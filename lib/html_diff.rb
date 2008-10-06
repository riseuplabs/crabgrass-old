require 'tempfile'

class HTMLDiff
  cattr_accessor :log_to_stdout

  def self.diff(a, b)

    f1 = Tempfile.new("crabgrass-diff-a")
    f1.write a
    f1.close
          
    f2 = Tempfile.new("crabgrass-diff-b")
    f2.write b
    f2.close

    arguments = [PYTHON_COMMAND, HTML_DIFF_COMMAND, f1.path, f2.path]
    success, output = cmd(*arguments)
    f1.unlink
    f2.unlink

    return output
  end

  def self.cmd(*args)
    cmdstr = args.collect{|arg| arg.shell_escape}.join(' ') 
    log cmdstr
    output = `#{cmdstr}`
    return [$?.success?, output]
  end

  def self.log(*args)
    ActiveRecord::Base.logger.info "HTML_Diff --- " + args.join(' ')
    puts args.join(' ') if log_to_stdout
  end

end

