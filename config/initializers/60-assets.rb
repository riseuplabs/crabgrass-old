
GM_COMMAND = `which gm`.chomp unless defined? GM_COMMAND
PYTHON_COMMAND = `which python`.chomp unless defined? PYTHON_COMMAND

if `which openoffice`.any?
  OPENOFFICE_DAEMON_PORT = 8100
  OPENOFFICE_COMMAND = "#{RAILS_ROOT}/lib/od_converter.py"
  OPENOFFICE_DAEMON_COMMAND = 'openoffice -headless -accept="socket,port=%s;urp;"' % OPENOFFICE_DAEMON_PORT
else
  OPENOFFICE_COMMAND = false
end

THUMBNAIL_SEPARATOR = '_'

AssetExtension::Storage.make_required_dirs

