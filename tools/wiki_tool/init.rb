PageClassRegistrar.add(
  'WikiPage',
  :controller => 'wiki_page',
  :icon => 'page_text',
  :class_display_name => 'wiki',
  :class_description => :wiki_class_description,
  :class_group => 'text',
  :order => 4
)

PageClassRegistrar.add(
  'ArticlePage',
  :controller => 'article_page',
  :icon => 'page_article',
  :class_display_name => 'article',
  :class_description => :article_class_description,
  :class_group => 'text',
  :order => 4
)

#self.override_views = true
self.load_once = false

