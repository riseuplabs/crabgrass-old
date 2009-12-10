Then /^the "([^\"]*)" select field should have "([^\"]*)" selected$/ do |name, option|
  assert field_named(name).value == option
end

