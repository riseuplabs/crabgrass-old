

Dispatcher.to_prepare {
  Language.send(:include, LanguageExtension)
}

self.override_views = false
self.load_once = false

