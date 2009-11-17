Given /^#{capture_model} is a member of #{capture_model}$/ do |user, group|
  model(group).add_user!(model(user))
end

Given /^#{capture_model} has (\d+) members$/ do |group, count|
  group = model(group)
  count.to_i.times do
    user = create_model('user').last
    group.add_user!(user)
  end
end


