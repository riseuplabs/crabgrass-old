
::YUCKY_RATING = -100

self.override_views = false
self.load_once = false

Dispatcher.to_prepare do
  Page.class_eval do
    acts_as_rateable
  end
  require 'page_view_listener'
  require 'super_admin_listener'
end

#apply_mixin_to_model(User, SuperAdminUserExtension)
