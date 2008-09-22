PageClassRegistrar.add(
  'Gallery',
  :controller => 'gallery',
  :icon => 'gallery.png',
  :class_display_name => 'gallery',
  :class_description => 'A collection of images.',
  :class_group => ['gallery'],
  :order => 31
)

# This doesn't work here, and I don't really know why
#Asset.class_eval do
#  has_many :showings
#  has_many :galleries, :through => :showings
#end

# this doesn't work either
#Asset.send(:include, AssetExtension::Gallery)

self.override_views = false
self.load_once = false

