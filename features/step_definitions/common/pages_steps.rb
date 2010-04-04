Then /^I should see #{capture_model}'s owner details$/ do |page|
  page = model(page)
  entity = I18n.t(((page.owner.is_a?(Group)) ? 'group' : 'user').to_sym).downcase
  page_details = I18n.t(:page_owned_by, :title => page.title, :entity => entity, :name => page.owner.display_name)
  Then "I should see \"#{page_details}\""
end

When /^I select ("[^\"]+") from my_work View$/ do |select_option|
  When "I select #{select_option} from select list named \"view_filter_select\""
end
