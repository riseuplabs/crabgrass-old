  
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
  :internal => true
)

self.load_once = false

