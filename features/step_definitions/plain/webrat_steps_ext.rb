Then /^the "([^\"]*)" select field should have "([^\"]*)" selected$/ do |name, option|
  assert field_named(name).value == option
end

When /^I select "([^\"]*)" from select list named "([^\"]*)"$/ do |value, field|
  select(value, :from => field)
end

Then /^I should see "([^\"]*)" translated(?: with #{capture_fields})?$/ do |key, fields|
  key=key.gsub(' ','_').to_sym
  substitutions = parse_fields(fields)
  assert_contain I18n.t(key, substitutions)
end
