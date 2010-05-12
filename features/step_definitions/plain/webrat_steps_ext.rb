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

Then /^I should see a link to "([^"]+)"$/ do |href|
  assert have_selector("a", :href => href)
end


# Modalbox links
When /^I follow and confirm "([^\"]*)"$/ do |link_name|
  When "I follow and confirm \"#{link_name}\" within \"body\""
end

When /^I follow and confirm "([^\"]*)" within (.*)$/ do |link_name, scope|
  parent = selector_for(scope)

  link = nil
  within(parent) do |scope|
    link = scope.find_link link_name
  end

  onclick = link.element["onclick"]
  if onclick =~ /Modalbox\.confirm/
    if onclick =~ /method:"(.*?)", action:"(.*?)"/
      method = $~[1]
      url = $~[2]
      visit(url, method.to_sym)
    else
      raise "no 'method' and 'action' keys found in Modalbox.confirm link #{link_name} <<#{onclick}>>"
    end
  else
    raise "#{link_name} is not a Modalbox.confirm link"
  end
end


Then /^show me the screenshot$/ do
  save_and_open_screengrab
end
