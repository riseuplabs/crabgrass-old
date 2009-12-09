Given /^#{capture_model} watch(?:es)? #{capture_model}$/ do |user, page|
  user = model(user)
  page = model(page)
  upart = page.add(user, :watch => true)
  upart.save!
end

# This should be changed to allow for {admin, edit, view} access.
Given /^#{capture_model} (?:has|have) (admin|edit|view) access to #{capture_model}$/ do |entity, level, page|
  entity = model(entity)
  access = case level
           when 'admin' then 1
           when 'edit' then 2
           when 'view' then 3
           end
  page = model(page)
  page.add entity, :access => access
  page.save
end

Given /^#{capture_model} notified #{capture_model} about #{capture_model}$/ do |sender, recipient, page|
  sender = model(sender)
  recipient = model(recipient)
  page = model(page)
  sender.share_page_with! page, recipient, :send_notice => true
end

Given /^#{capture_model} owns #{capture_model}$/ do |owner, page|
  owner = model(owner)
  page = model(page)
  page.owner=owner
end

