# this should not exist:
#PageClassRegistrar.add(
#  'Page',
#  :controller => 'page',
#  :class_display_name => 'basic page'
#)
  
PageClassRegistrar.add(
  'DiscussionPage',
  :controller => 'discussion_page',
  :icon => 'page_discussion',
  :class_group => ['text', 'discussion'],
  :order => 2
)

PageClassRegistrar.add(
  'MessagePage',
  :controller => 'message_page',
  :icon => 'page_message',
  :class_group => ['text', 'discussion'],
  :order => 3
)


#self.override_views = true
self.load_once = false

