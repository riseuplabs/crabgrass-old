
GM_COMMAND       = `which gm`.chomp       unless defined? GM_COMMAND
PYTHON_COMMAND   = `which python`.chomp   unless defined? PYTHON_COMMAND
FFMPEG_COMMAND   = `which ffmpeg`.chomp   unless defined? FFMPEG_COMMAND
INKSCAPE_COMMAND = `which inkscape`.chomp unless defined? INKSCAPE_COMMAND
GPG_COMMAND      = `which gpg`.chomp      unless defined? GPG_COMMAND

if `which openoffice`.any?
  OPENOFFICE_DAEMON_PORT = 8100
  OPENOFFICE_COMMAND = "#{RAILS_ROOT}/lib/od_converter.py"
  OPENOFFICE_DAEMON_COMMAND = 'openoffice -headless -accept="socket,port=%s;urp;"' % OPENOFFICE_DAEMON_PORT
else
  OPENOFFICE_COMMAND = false
end

THUMBNAIL_SEPARATOR = '_'

# uncomment this to print out what the hell the processors are doing.
# Media::Process::Base.log_to_stdout_when = :always

AssetExtension::Storage.make_required_dirs

