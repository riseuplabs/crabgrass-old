%w(string core action_pack active_record engines).each do |file|
  require "#{RAILS_ROOT}/lib/extension/#{file}"
end

require "#{RAILS_ROOT}/lib/greencloth/text_sections.rb"
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

