::YUCKY_RATING = -100

self.override_views = false
self.load_once = false


Dispatcher.to_prepare do
  Page.class_eval do
    acts_as_rateable
  end
  require 'moderation_listener'
  require 'page_view_listener'
  
  apply_mixin_to_model(Site, ModerationSiteExtension)
end
