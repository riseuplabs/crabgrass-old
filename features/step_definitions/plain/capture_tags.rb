# this is for marking pages in a list. It could probably be
# generalized for other objects.
When /^I mark #{capture_model}$/ do |page|
  page=model(page)
  # check field_with_id("page_checked_#{page.id}")
  When "I check \"page_checked_#{page.id}\""
end
