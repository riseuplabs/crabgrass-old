self.override_views = true
self.load_once = false

Dispatcher.to_prepare do
  require 'add_job_listener'
end
