# this is for marking pages in a list. It could probably be
# generalized for other objects.
When /^I mark #{capture_model}$/ do |page|
  page = model(page)
  # check field_with_id("page_checked_#{page.id}")
  When "I check \"page_checkbox_#{page.id}\""
end

Then /^I should see #{capture_model}'s (\w+)$/ do |entity, property|
  entity = model(entity)
  term = entity.send(property.to_sym)
  # check field_with_id("page_checked_#{page.id}")
  Then "I should see \"#{term}\""
end
