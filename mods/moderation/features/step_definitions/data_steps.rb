Given /^I am a moderator of #{capture_model}$/ do |group|
  Given "I am an admin of #{group}"
  Given "#{group} has moderation enabled"
end

Given /^#{capture_model} has moderation enabled$/ do |group|
  group.admin_may_moderate = true
end
