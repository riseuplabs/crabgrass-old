
$: << 'lib/crabgrass'

RAILS_ENV = 'development'
RAILS_ROOT = '/data/dev/crabgrass.git'
require 'lib/crabgrass/theme'

theme = Crabgrass::Theme['default']

theme.navigation.root.each do |nav_element|
  puts nav_element.visible
end

