begin
  require File.join(File.dirname(__FILE__), 'lib', 'haml') # From here
rescue LoadError
  require 'haml' # From gem
end

# Load Haml and Sass.
# Haml may be undefined if we're running gems:install.
Haml.init_rails(binding) if defined?(Haml)
