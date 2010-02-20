Given /^Navigation exists$/ do
  @nav = Navigation.new
end

When /^I am navigating from the root of the menu structure$/ do
  if @nav.nil?
    raise "No instance variable @nav!"
  end
  if @nav.structure.nil?
    raise "No structure in @nav!"
  end
  @submenu = @nav.structure
  When "I am on the homepage"
end

Then /^show the current navigation submenu$/ do
  puts @submenu.inspect
end

Then /^I should be able to click through "(.*)"(?: in level (\d) navigation)$/ do |key, n|
  n = @submenu[key]['nav_level'] || n.to_i
  @submenu=@submenu[key]
  puts %(following "#{key}" in #{n})
  n+=1
  When %(I follow "#{key}")
  Then "I should see the submenu links in level #{n} navigation"
  And "the submenu links should have the right path"
  And "I should be able to click through all of the level #{n} links"
end

Then /^I should see (?:all (?:of )?)?the submenu links(?: in level (\d) navigation)?$/ do |n|
  n = n.to_i
  @submenu.each_pair do |key, value|
    debugger
    if value.is_a? Hash
      if value['outside_nav'] or n == 0
        Then %(I should see "#{key}")
      else
        Then %(I should see "#{key}" within "the level #{n} navigation")
      end
    end
  end
end

Then /^the submenu links should have the right path(?: from ([\w\/]*))?$/ do |parent_path|
  parent_path ||= ""
  @submenu.each_pair do |key, value|
    if value.is_a? Hash
      path = value[:path] || parent_path + '/' + key.downcase
      puts "#{key} should link to #{path}"
    end
  end
end

Then /^I should be able to click through all of the (?:level (\d) )?links$/ do |n|
  n ||= 1
  n = n.to_i
  menu=@submenu
  menu.each_pair do |key, value|
    if value.is_a? Hash
      Then %(I should be able to click through "#{key}" in level #{n} navigation)
    end
    @submenu=menu
  end
end

