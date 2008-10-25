PageClassRegistrar.add(
  'Page',
  :controller => 'page',
  :class_display_name => 'basic page'
)
  
PageClassRegistrar.add(
  'DiscussionPage',
  :controller => 'discussion_page',
  :icon => 'discussion.png',
  :class_display_name => 'group discussion',
  :class_description => :group_discussion_class_description,
  :class_group => 'discussion',
  :order => 2
)

PageClassRegistrar.add(
  'MessagePage',
  :controller => 'message_page',
  :icon => 'message.png',
  :class_display_name => 'personal message',
  :class_description => :personal_message_class_description,
  :class_group => 'message',
  :order => 1
)


#self.override_views = true
self.load_once = false

