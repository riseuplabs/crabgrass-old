##
## if rmagick is not installed, then we make mini_magick simulate rmagick.
##

begin
  require 'RMagick'
rescue MissingSourceFile => e
  puts %{FYI: minimagick is simulating rmagick}
  
  require 'mini_magick'
  require 'image_temp_file'

end
