Then /^the "([^\"]*)" select field should have "([^\"]*)" selected$/ do |name, option|
  assert field_named(name).value == option
end

When /^I select "([^\"]*)" from select list named "([^\"]*)"$/ do |value, field|
  select(value, :from => field)
end

