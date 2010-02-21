When /^I am navigating from the root of #{capture_model}$/ do |nav|
  nav = model(nav).root
  if nav.nil?
    raise "No instance variable @nav!"
  end
  if nav.children.nil?
    raise "No structure in @nav!"
  end
  When "I am on the homepage"
end

Then /^show the menu structure of #{capture_model}$/ do |nav|
  nav = model(nav)
  nav.printTree
end

Then /^I should be able to click through #{capture_model}$/ do |nav|
  nav = model(nav)
  unless nav.isRoot?
    puts %(When I follow "#{nav.name}" within "#{nav.scope}")
    When %(I follow "#{nav.name}" within "#{nav.scope}")
  end
  nav.children.each do |child|
    puts "#{child.name}: #{child.scope}"
    Then %(I should see "#{child.name}" within "#{child.scope}")
  #  Then %(I should see "#{child.name}" within "a link to #{child.path}")
    And "a navigation should exist with id: #{child.id}"
    if child.visit?
      And 'I should be able to click through that navigation'
    end
  end
  visit nav.path
end


