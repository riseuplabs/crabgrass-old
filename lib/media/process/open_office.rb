require 'socket'

module Media::Process
  class OpenOffice < Processor

    def to_sym; :open_office; end

    def available?
      return false unless PYTHON_COMMAND.any? and OPENOFFICE_COMMAND.any? and File.exists?(OPENOFFICE_COMMAND)
      unless daemon_running?
        try_starting_daemon
        sleep 1
      end
      daemon_running?
    end

    def try_starting_daemon
      log 'attempting to start openoffice in daemon mode: %s' % OPENOFFICE_DAEMON_COMMAND
      unless system(OPENOFFICE_DAEMON_COMMAND)
        log_error 'not able to start openoffice'
      end
    end

    def daemon_running?
      begin
        TCPSocket.new 'localhost', OPENOFFICE_DAEMON_PORT
        return true
      rescue Errno::ECONNREFUSED
        return false
      end
    end

    def run(options)
      # TODO: pick which python to use. on some platforms, we may need to run
      # an openoffice specific python.
      arguments = [PYTHON_COMMAND, OPENOFFICE_COMMAND, options[:in], options[:out]]
      success, output = cmd(*arguments)
      return success
    end

  end
end
