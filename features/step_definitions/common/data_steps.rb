Given /^#{capture_model} is a member of #{capture_model}$/ do |user, group|
  model(group).add_user!(model(user))
end

# this could be included in the previous step, but it corrupts up cucumber output a bit
Given /^I am a member of #{capture_model}$/ do |group|
  Given "user: \"me\" is a member of #{group}"
end

Given /^#{capture_model} has (\d+) members$/ do |group, count|
  group = model(group)
  count.to_i.times do
    user = create_model('user').last
    group.add_user!(user)
  end
end

Given /^#{capture_model} has (\d+) (?:other) members$/ do |group, count|
  Given "#{group} has #{count} members"
end

Given /^#{capture_model} has a council$/ do |group|
  group = model(group)
  council = create_model('a council').last

  # true means this is a council, not just any committee
  group.add_committee!(council, true)
end

Given /^#{capture_model} has a committee(?: with #{capture_fields})$/ do |group, committee_fields|
  group = model(group)
  committee = create_model('a committee', committee_fields).last

  # false means this is not a council
  group.add_committee!(committee, false)
end

Given /^#{capture_model} (?:has|have) proposed to destroy #{capture_model}$/ do |user, group|
  user = model(user)
  group = model(group)

  RequestToDestroyOurGroup.create! :created_by => user, :recipient => group
end

When /^I wait 1 month$/ do
  assert $browser.nil?, "Can not stub Time.now with browser javascript tests because the server is a separate process"

  future_time = 1.month.from_now
  Time.stubs(:now).returns(future_time)

  Given "cron tasks have been executed"
end

When /^#{capture_model} (approve|reject)s? the proposal to destroy #{capture_model}$/ do |user, operation, group|
  user = model(user)
  group = model(group)

  request = RequestToDestroyOurGroup.pending.for_group(group).last
  assert request, "RequestToDestroyOurGroup has to exist to be approved or rejected"

  # operation = :approve_by!
  operation = (operation + "_by!").to_sym

  request.send(operation, user)
end





