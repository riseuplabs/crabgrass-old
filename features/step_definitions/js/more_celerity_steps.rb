# find nearest checkbox for element with id
def find_nearest_chebox(id)
end


When /I select "(.*)" from select list named "(.*)"/ do |value, field|
  $browser.select_list(:name, field).select value
end

Then /^the "([^\"]*)" select field should have "([^\"]*)" selected$/ do |name, option|
  assert $browser.select_list(:name, name).value == option
end

Then /the text field named "([^\"]*)" should contain "([^\"]*)"$/ do |name, value|
  assert $browser.text_field(:name, name).value == value
end

When /I fill in the field named "([^\"]*)" with "([^\"]*)"$/ do |name, value|
  $browser.text_field(:name, name).set(value)
end

When /I fire the "([^\"]*)" event on the element named "([^\"]*)"$/ do |event, name|
  $browser.text_field(:name, name).fire_event(event)
end

When /I check the checkbox with id "(.*)"/ do |id|
  $browser.check_box(:id, id).set(true)
end

When /I check the checkbox for "(.*)"/ do |label|
  # try different items for label
  require 'ruby-debug';debugger;1-1
  field = $browser.text_field(:name, label)
end

Then /^I should see "([^\"]*)" translated(?: with #{capture_fields})?$/ do |key, fields|
  key=key.gsub(' ','_').to_sym
  substitutions = parse_fields(fields)
  Then "I should see \"#{I18n.t(key, substitutions)}\""
end

# for debugging
Then /^show me the div with id \"([^\"]+)\"$/ do |id|
  puts "CONTENT FOR div #{id} is:\n----------------"
  puts $browser.div(:id, id).html
end
