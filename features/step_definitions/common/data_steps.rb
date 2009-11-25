Given /^#{capture_model} is a member of #{capture_model}$/ do |user, group|
  model(group).add_user!(model(user))
end

# this could be included in the previous step, but it corrupts up cucumber output a bit
Given /^I am a member of #{capture_model}$/ do |group|
  Given "user: \"me\" is a member of #{group}"
end

Given /^#{capture_model} has (\d+) (?:other) members$/ do |group, count|
  group = model(group)
  count.to_i.times do
    user = create_model('user').last
    group.add_user!(user)
  end
end

Given /^#{capture_model} has a council$/ do |group|
  group = model(group)
  council = create_model('a council').last

  # true means this is a council, not just any committee
  group.add_committee!(council, true)
end

Given /^#{capture_model} has admins moderate content$/ do |group|
  group = model(group)
  group.admins_moderate_content = true
end

# This should be changed to allow for {admin, edit, view} access.
Given /^#{capture_model} has admin access to #{capture_model}$/ do |entity, page|
  entity = model(entity)
  page = model(page)
  page.add entity, :access => 1
  page.save
end

Given /^#{capture_model} comments #{capture_model} ?(?: with #{capture_fields})?$/ do |post, page, fields|
  page = model(page)
  post = create_model(post, fields).last
  post = page.build_post(post, post.user)
  post.save!
  page.save!
end

Given /^(\d+) Posts comment #{capture_model}$/ do |count, page|
  page = model(page)
  count.to_i.times do
    post = create_model('post').last
    post = page.build_post(post, post.user)
    post.save!
  end
  page.save!
end
