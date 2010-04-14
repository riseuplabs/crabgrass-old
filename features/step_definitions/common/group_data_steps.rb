Given /^#{capture_model} is a member of #{capture_model}$/ do |user, group|
  model!(group).add_user!(model!(user))
end

# this could be included in the previous step, but it corrupts up cucumber output a bit
Given /^I am a member of #{capture_model}$/ do |group|
  Given "user: \"me\" is a member of #{group}"
end

Given /^#{capture_model} has (\d+) members$/ do |group, count|
  group = model!(group)
  count.to_i.times do
    user = create_model('user').last
    group.add_user!(user)
  end
end

Given /^#{capture_model} has (\d+) (?:other) members$/ do |group, count|
  Given "#{group} has #{count} members"
end

Given /^#{capture_model} has a council$/ do |group|
  group = model!(group)
  council = create_model('a council').last

  # true means this is a council, not just any committee
  group.add_committee!(council, true)
end

# create group memberships from a table
Given(/^#{capture_model} has the following members:$/) do |group, table|
  group = model!(group)
  table.hashes.each do |hash|
    name = extract_model_label_from_table_hash!("user", hash)
    user = model!(name)
    group.add_user!(user)
  end
end

Given /^#{capture_model} has committees (.*)$/ do |group, committees|
  group = model!(group)
  committees.gsub!(/\s/, '')
  committees.split(',').each do |committee|
    committee = create_model('a committee', {:name => committee}).last
    # false means this is not a council
    group.add_committee!(committee, false)
  end
end

Given /^#{capture_model} has a committee(?: with #{capture_fields})$/ do |group, committee_fields|
  group = model!(group)
  committee = create_model('a committee', committee_fields).last

  # false means this is not a council
  group.add_committee!(committee, false)
end

Then /^#{capture_model} should not be a member of #{capture_model}$/ do |user, group|
  group = model!(group)
  user = model!(user)

  assert !user.member_of?(group)
end

Given /^#{capture_model}(?:'s)? country is "([^\"]+)"$/ do |group, country|
  group = model!(group)
  gl = GeoLocation.make(:geo_country_id => 2)
  profile = Profile.make(:entity => group, :stranger => 1, :peer => 1, :friend => 1, :geo_location_id => gl.id, :may_see=>1)
  profile.save!
end
