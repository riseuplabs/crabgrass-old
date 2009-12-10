Given /^geo data exists$/ do
  Given "a geo_country exists with name: \"United States\", code: \"US\""
  Given "a geo_country exists with name: \"Netherlands\", code: \"NL\""
  Given "a geo_admin_code exists with name: \"Philadelphia\", geo_country_id: 1, admin1_code: \"PA\""
  Given "a geo_admin_code exists with name: \"Washington\", geo_country_id: 1, admin1_code: \"WA\""
  Given "a geo_admin_code exists with name: \"Utrecht\", geo_country_id: 2, admin1_code: \"09\""
end

Given /set the country "([^\"]*)"$/ do |country|
  Given "I select \"#{country}\" from \"profile[country_id]\""
end

Given /should see #{capture_model} country selected$/ do |group|
  group = model!(group)
  Given "the \"profile[country_id]\" select field should have \"#{group.geo_location.geo_country_id}\" selected"
end
