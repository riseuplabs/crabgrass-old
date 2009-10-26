#!/usr/bin/env ruby

require 'pathname'
require 'yaml'
require 'erb'

$environment = 'production'

$root = Pathname.new(__FILE__).dirname.dirname.realpath
$backgroundrb_config_file = "#{$root}/config/backgroundrb.yml"
$sphinx_config_file = "#{$root}/config/#{$environment}.sphinx.conf"
$sphinx_db_file = "#{$root}/db/sphinx/production/page_terms_core.sph"
$ts_config_file = "#{$root}/config/sphinx.yml"
$backgroundrb_port = 0

Dir.chdir $root

def process_command
  case ARGV[0]
  when 'start'
    start_sphinx
    ensure_stop_backgroundrb    # make sure it is dead before we try to start it
    sleep 1                     # otherwise it might not start and might not give us an error
    start_backgroundrb
  when 'stop'
    stop_sphinx
    stop_backgroundrb
  when 'restart'
    restart_sphinx
    stop_backgroundrb
    sleep 1
    start_backgroundrb
  when 'restart-sphinx'
    restart_sphinx
  when 'restart-bgrb'
    stop_backgroundrb
    sleep 1
    start_backgroundrb
  when 'status'
    status_sphinx
    status_backgroundrb
  when 'status-sphinx'
    status_sphinx
  when 'status-bgrb'
    status_backgroundrb
  when 'start-sphinx'
    start_sphinx
  when 'stop-sphinx'
    stop_sphinx
  when 'start-bgrb'
    start_backgroundrb
  when 'stop-bgrb'
    stop_backgroundrb
  end
end

##
## SPHINX
##

def ensure_sphinx_config
  assert_file_exists($ts_config_file)
  unless File.exists? $sphinx_config_file
    puts 'No sphinx configuration exists, creating one (%s)' % $sphinx_config_file
    system("rake thinking_sphinx:configure RAILS_ENV=#{$environment}")
    assert_file_exists($sphinx_config_file)
  end
  unless File.exists? $sphinx_db_file
    puts "No sphinx db exists... creating index now"
    system("rake thinking_sphinx:index RAILS_ENV=#{$environment}")
  end
end

def restart_sphinx
  ensure_sphinx_config
  system("rake thinking_sphinx:running_start RAILS_ENV=#{$environment}")
end

def start_sphinx
  ensure_sphinx_config
  puts "Starting sphinx searchd..."
  system("rake thinking_sphinx:start RAILS_ENV=#{$environment}")
end

def stop_sphinx
  puts "Stopping sphinx searchd..."
  system("rake thinking_sphinx:stop RAILS_ENV=#{$environment}")
  pid = `pgrep searchd`.chomp
  if pid.any?
    puts "  ERROR: searchd is still running with process id %s" % pid
  end
end

def status_sphinx
  pid = `pgrep searchd`.chomp
  if pid.any?
    puts "Sphinx searchd running"
    puts "  process id %s" % pid
    puts "  running for %s" % process_elapsed_time(pid)
  else
    puts "Sphinx searchd NOT running."
    exit 1
  end
end

##
## BACKGROUNDRB
##

def bgrb_pid
  `pgrep -f 'backgroundrb master'`.chomp
end

def load_backgroundrb_config
  $brb_config ||= begin
    assert_file_exists($backgroundrb_config_file)
    conf = YAML::load(ERB.new(IO.read($backgroundrb_config_file)).result)
    $backgroundrb_port = conf[:backgroundrb][:port]
    $backgroundrb_pid_file = "#{$root}/tmp/pids/backgroundrb_#{$backgroundrb_port}.pid"
    conf
  end
end

def start_backgroundrb
  pid_dir = "#{$root}/tmp/pids"
  Dir.mkdir(pid_dir) unless File.exists?(pid_dir)
  # this is echoed by the BackgrounDRb::StartStop
  # puts "Starting backgroundrb..."
  puts ""
  system("#{$root}/script/backgroundrb start -e #{$environment}")

  if (pid = bgrb_pid).any?
    puts "Started backgroundrb successfuly (pid %s)." % pid
  else
    puts "ERROR: could not start backgroundrb."
  end
  if (pids = `pgrep -f packet_worker_runner`.gsub("\n", " ").strip).any?
    puts "Started packet workers successfully (pids %s)." % pids
  else
    puts "ERROR: could not start packet_worker_runner"
  end
end

def stop_backgroundrb
  pid = bgrb_pid
  if pid.empty?
    puts "Backgroundrb is not running."
    return
  end
  puts "Stopping backgroundrb daemon..."
  system("#{$root}/script/backgroundrb stop -e #{$environment}")
  system("pkill -f 'script/backgroundrb'") # make sure it is dead
  sleep 1
  if bgrb_pid.any?
    puts "ERROR: failed to stop backgroundrb (%s)." % bgrb_pid
  else
    puts "Stopped backgroundrb daemon (pid %s)." % pid
  end
end

def ensure_stop_backgroundrb
  if bgrb_pid.any?
    system("#{$root}/script/backgroundrb stop -e #{$environment}")
    system("pkill -f 'script/backgroundrb'") # make sure it is dead
  end
end

def status_backgroundrb
  load_backgroundrb_config
  pid = bgrb_pid
  if pid.any?
    puts "Backgroundrb running"
    puts "  process id %s" % pid
    puts "  running for %s" % process_elapsed_time(pid)
    if !File.exists?($backgroundrb_pid_file)
      puts "  WARNING: file does not exist %s" % $backgroundrb_pid_file
    elsif pid != File.read($backgroundrb_pid_file)
      puts "  WARNING: pid %s does not match contents of file %s (%s)" % [pid, $backgroundrb_pid_file, File.read($backgroundrb_pid_file)]
    end
  else
    puts "Backgroundrb NOT running."
    if File.exists?($backgroundrb_pid_file)
      puts "  WARNING: file %s exists (contents: %s)" % [$backgroundrb_pid_file, File.read($backgroundrb_pid_file)]
    end
    exit 1
  end
  pids = `pgrep -f packet_worker_runner`.chomp.split("\n")
  pids.each do |pid|
    puts "  packet_worker_runner: pid=%s time=%s" % [pid, process_elapsed_time(pid)]
  end
end

##
## UTILITY
##

def process_elapsed_time(pid)
  time = `ps -p #{pid} -o "%t"`.chomp.split("\n")[1]
  return 'unknown' unless time
  time = time.strip
  if time =~ /-/
    days, time = time.split('-')
  else
    days = 0
  end
  times = time.split(':')
  times.unshift(0) if times.size < 3
  times.unshift(0) if times.size < 3
  hours, minutes, seconds = times
  "#{days}d,#{hours}h:#{minutes}m:#{seconds}s"
end

def assert_file_exists(filename)
  unless File.exists?(filename)
    puts "ERROR: file not found: %s" % filename
    puts "Bailing out."
    exit
  end
end

##
## EXECUTION
##

process_command
exit

