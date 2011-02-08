self.override_views = false
self.load_once = false

Dispatcher.to_prepare do
  require 'enhanced_stats_view_listener'
  require 'enhanced_stats_activerecord_extension'
  apply_mixin_to_model(Post, StatsPostExtension)
  apply_mixin_to_model(PageHistory, StatsPageHistoryExtension)
end

