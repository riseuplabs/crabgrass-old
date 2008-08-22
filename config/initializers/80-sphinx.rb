# test if searchd is running, if not set ThinkingSphinx.updates_enabled to false

require 'fileutils'

def sphinx_pid
  config = ThinkingSphinx::Configuration.new
  
  if File.exists?(config.pid_file)
    `cat #{config.pid_file}`[/\d+/]
  else
    nil
  end
end

def sphinx_running?
  sphinx_pid && `ps -p #{sphinx_pid} | wc -l`.to_i > 1
end

if sphinx_running?
  ThinkingSphinx.updates_enabled = true
else
  ThinkingSphinx.updates_enabled = false
end

