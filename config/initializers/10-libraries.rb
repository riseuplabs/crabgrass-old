require "#{RAILS_ROOT}/lib/extends_to_core.rb"
require "#{RAILS_ROOT}/lib/extends_to_active_record.rb"
require "#{RAILS_ROOT}/lib/extends_to_action_pack.rb"
require "#{RAILS_ROOT}/lib/greencloth/greencloth.rb"
require "#{RAILS_ROOT}/lib/path_finder.rb"
require "#{RAILS_ROOT}/lib/page_class_proxy.rb"
require "#{RAILS_ROOT}/lib/i18n_helpers.rb"

require "#{RAILS_ROOT}/lib/crabgrass/hook.rb"
Dispatcher.to_prepare do
  # I don't understand why this is needed for crabgrass, but not for redmine
  ApplicationHelper.send(:include, Crabgrass::Hook::Helper)
end

# model extensions:
require "#{RAILS_ROOT}/app/models/tag.rb"

