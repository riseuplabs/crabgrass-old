When /I select "(.*)" from select list named "(.*)"/ do |value, field|
  $browser.select_list(:name, field).select value
end

Then /^the "([^\"]*)" select field should have "([^\"]*)" selected$/ do |name, option|
  assert $browser.select_list(:name, name).value == option
end

