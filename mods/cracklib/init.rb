self.load_once = false

if File.exists?('/usr/sbin/cracklib-check')
  ::CRACKLIB_COMMAND = '/usr/sbin/cracklib-check'
else
  ::CRACKLIB_COMMAND = `which cracklib-check`.chomp
end

if CRACKLIB_COMMAND.any?

  require 'cracklib'
  require 'cracklib_view_listener'

  Dispatcher.to_prepare do
    apply_mixin_to_model(User, CracklibUserExtension)
  end

else

  puts 'ERROR: command cracklib-check not found. Either install package "cracklib-runtime" or disable the cracklib crabgrass mod.'
  exit

end

