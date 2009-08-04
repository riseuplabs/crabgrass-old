
self.override_views = false
self.load_once = false

Dispatcher.to_prepare do
  require 'super_admin_listener'
end

apply_mixin_to_model(Site, SiteExtension)

#apply_mixin_to_model(User, SuperAdminUserExtension)
