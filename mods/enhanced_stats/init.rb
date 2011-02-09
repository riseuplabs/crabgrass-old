self.override_views = false
self.load_once = false

Dispatcher.to_prepare do
  require 'enhanced_stats_view_listener'
  apply_mixin_to_model(User, StatsUserExtension)
  apply_mixin_to_model(Group, StatsGroupExtension)
  apply_mixin_to_model(Page, StatsPageExtension)
  apply_mixin_to_model(Post, StatsPostExtension)
  apply_mixin_to_model(PageHistory, StatsPageHistoryExtension)
end

