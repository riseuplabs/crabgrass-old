Given /^the following authentications:$/ do |authentications|
  Authentication.create!(authentications.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) authentication$/ do |pos|
  visit authentications_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following authentications:$/ do |expected_authentications_table|
  expected_authentications_table.diff!(table_at('table').to_a)
end
