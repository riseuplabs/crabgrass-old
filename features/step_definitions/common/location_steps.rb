Given /^geo data exists$/ do
  Given "a geo_country exists with name: \"United States\", code: \"US\""
  Given "a geo_country exists with name: \"Netherlands\", code: \"NL\""
  Given "a geo_admin_code exists with name: \"Philadelphia\", geo_country_id: 1, admin1_code: \"PA\""
  Given "a geo_admin_code exists with name: \"Washington\", geo_country_id: 1, admin1_code: \"WA\""
  Given "a geo_admin_code exists with name: \"Utrecht\", geo_country_id: 2, admin1_code: \"09\""
  Given "a geo_place exists with name: \"Utrecht\", geo_country_id: 2, geo_admin_code_id: \"3\""
end

Transform /^country \w+$/ do |step_arg|
  GeoCountry.find_by_name /(\w+)$/.match(step_arg)[0]
end

Transform /^state \w+ in country \w+$/ do |step_arg|
  country =  GeoCountry.find_by_name /country (\w+)$/.match(step_arg)[1] 
  state = country.geo_admin_codes.find_by_name /^state (\w+) in/.match(step_arg)[1]
  [country, state]
end

When /set the country "([^\"]*)"$/ do |country|
  When "I select \"#{country}\" from select list named \"profile[country_id]\""
end

When /search by country "([^\"]*)"$/ do |country|
  When "I select \"#{country}\" from select list named \"country_id\""
end

#When /select country "([^\"]*)" from select list "([^\"]*)"$/ do |country, select_name|
#  When "I select \"#{country}\" from select list named \"#{select_name}\""
#end

When /set the state "([^\"]*)"$/ do |state|
  When "I select \"#{state}\" from select list named \"profile[state_id]\""
end

When /search by state "([^\"]*)"$/ do |state|
  When "I select \"#{state}\" from select list named \"state_id\""
end

When /set the city "([^\"]*)"$/ do |city|
  When "I fill in the field named \"profile[geo_city_name]\" with \"#{city}\"" 
  And "I fire the \"blur\" event on the element named \"profile[geo_city_name]\""
  And "I wait for the AJAX call to finish"
  ## this needs work to dynamically find the id, though if we're using exact matching city names it should just work
  #And "I check the checkbox with id \"city_with_id_1\""
end

Then /should see matching city results$/ do
  Then "I should see \"Utrecht\""
end

Then /^(country \w+) should be selected$/ do |country|
  Then "country id #{country.id} should be selected"
end

Then /^country id (\d+) should be selected$/ do |country_id|
  Then "the \"profile[country_id]\" select field should have \"#{country_id}\" selected"
end

Then /^(country \w+) should be selected in the search form$/ do |country|
  Then "country id #{country.id} should be selected in the search form"
end

Then /^country id (\d+) should be selected in the search form$/ do |country_id|
  Then "the \"country_id\" select field should have \"#{country_id}\" selected"
end

Then /^(state \w+ in country \w+) should be selected$/ do |res|
  Then "the \"profile[state_id]\" select field should have \"#{res[1].id}\" selected"
  Then "country id #{res[0].id} should be selected"
end

Then /should see #{capture_model}(?:'s)? country selected$/ do |group|
  group = model!(group)
  Then "the \"profile[country_id]\" select field should have \"#{group.profile.geo_location.country_id}\" selected"
end

Then /city should be set to "([^\"]*)"$/ do |city|
  Then "the text field named \"profile[geo_city_name]\" should contain \"#{city}\""
end

