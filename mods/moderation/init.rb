::YUCKY_RATING = -100

self.override_views = false
self.load_once = false


Dispatcher.to_prepare do
  Page.class_eval do
    acts_as_rateable
  end
  ChatMessage.class_eval do
    acts_as_rateable
    alias_method :created_by, :sender
  end

  require 'moderation_listener'
  require 'page_view_listener'
  require 'chat_view_listener'

  apply_mixin_to_model(Site, ModerationSiteExtension)
  apply_mixin_to_model(User, UserFlagExtension)
  apply_mixin_to_model(Page, PageFlagExtension)
  apply_mixin_to_model(Post, PostFlagExtension)
  apply_mixin_to_model(Group, GroupModerationExtension)
end
