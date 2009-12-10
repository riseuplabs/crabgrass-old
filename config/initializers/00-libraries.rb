%w(string i18n core action_pack active_record active_record_validations engines).each do |file|
  require "#{RAILS_ROOT}/lib/extension/#{file}"
end

require "#{RAILS_ROOT}/lib/path_finder.rb"

# model extensions:
require "#{RAILS_ROOT}/app/models/tag.rb"
