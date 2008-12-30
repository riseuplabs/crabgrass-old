begin

  begin
    require File.join(File.dirname(__FILE__), 'lib', 'haml') # From here
  rescue LoadError
    require 'haml' # From gem
  end

  # Load Haml and Sass
  Haml.init_rails(binding)
  
rescue Exception => exc
  puts "WARNING: haml is disabled...."
  puts "         " + exc.to_s
end
