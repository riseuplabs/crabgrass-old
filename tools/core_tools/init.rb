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
  :class_description => 'A group discussion on a particular topic.',
  :class_group => 'discussion',
  :order => 2
)

PageClassRegistrar.add(
  'InfoPage',
  :controller => 'info_page',
  :icon => 'info.png',
  :class_group => 'info',
  :internal => true
)

PageClassRegistrar.add(
  'MessagePage',
  :controller => 'message_page',
  :icon => 'message.png',
  :class_display_name => 'personal message',
  :class_description => 'A personal message sent to individual recipients.',
  :class_group => 'message',
  :order => 1
)

PageClassRegistrar.add(
  'RequestDiscussionPage',
  :controller => 'request_discussion_page',
  :internal => true
)

PageClassRegistrar.add(
  'RequestPage',
  :controller => 'request_page',
  :icon => 'bullhorn.png',
  :class_group => 'request',
  :model => 'Poll',
  :internal => true
) 

#self.override_views = true
self.load_once = false

