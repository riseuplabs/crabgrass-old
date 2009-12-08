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