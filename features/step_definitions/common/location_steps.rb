Given /^geo data exists$/ do
  Given "a geo_country exists with name: \"United States\", code: \"US\""
  Given "a geo_country exists with name: \"Netherlands\", code: \"NL\""
  Given "a geo_admin_code exists with name: \"Philadelphia\", geo_country_id: 1, admin1_code: \"PA\""
  Given "a geo_admin_code exists with name: \"Washington\", geo_country_id: 1, admin1_code: \"WA\""
  Given "a geo_admin_code exists with name: \"Utrecht\", geo_country_id: 2, admin1_code: \"09\""
end

Transform /^country \w+$/ do |step_arg|
  GeoCountry.find_by_name /(\w+)$/.match(step_arg)[0]
end

When /set the country "([^\"]*)"$/ do |country|
  Given "I select \"#{country}\" from select list named \"profile[country_id]\""
end

When /set the county "([^\"]*)"$/ do |county|
  Given "I select \"#{county}\" from select list named \"profile[state_id]\""
end


Then /^(country \w+) should be selected$/ do |country|
  Then "the \"profile[country_id]\" select field should have \"#{country.id}\" selected"
end


Given /should see #{capture_model}(?:'s)? country selected$/ do |group|
  group = model!(group)
  Then "the \"profile[country_id]\" select field should have \"#{group.profile.geo_location.country_id}\" selected"
#  Then "the \"profile[country_id]\" select field should have \"1\" selected"
end
