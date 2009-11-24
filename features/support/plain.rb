def delivered_emails
  ActionMailer::Base.deliveries
end

require 'cucumber/webrat/element_locator' # Lets you do table.diff!(element_at('#my_table_or_dl_or_ul_or_ol').to_table)

require 'webrat'
require 'webrat/core/matchers'
Webrat.configure do |config|
  config.mode = :rails
  config.open_error_files = false # Set to true if you want error pages to pop up in the browser
end

# Beware that turning transactions off will leave data in your database
# after each scenario, which can lead to hard-to-debug failures in
# subsequent scenarios. If you do this, we recommend you create a Before
# block that will explicitly put your database in a known state.
Cucumber::Rails::World.use_transactional_fixtures = true
