self.load_once = false

# This is the time in years a password should hold for a brute force attack at
# minimum, assuming 1000 attempts per second.
unless defined? ::MIN_PASSWORD_STRENGTH
 ::MIN_PASSWORD_STRENGTH = 2
end

require 'password_strength'
require 'password_strength_view_listener'

Dispatcher.to_prepare do
  apply_mixin_to_model(User, PasswordStrengthUserExtension)
end

