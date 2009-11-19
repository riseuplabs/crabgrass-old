Given /^#{capture_model} is a member of #{capture_model}$/ do |user, group|
  model(group).add_user!(model(user))
end

Given /^I am a member of #{capture_model}$/ do |group|
  user=@controller.current_user
  model(group).add_user!(user) unless user.member_of?(model(group))
end

Given /^I am an admin of #{capture_model}$/ do |group|
  Given "I am a member of #{group}"
  Given "#{group} has a council"
  Given "I am a member of that council"
end

Given /^#{capture_model} has (\d+) members$/ do |group, count|
  group = model(group)
  count.to_i.times do
    user = create_model('user').last
    group.add_user!(user)
  end
end

Given /^#{capture_model} has a council$/ do |group|
  group = model(group)
  council = create_model('council').last
  group.add_committee!(council)
end
