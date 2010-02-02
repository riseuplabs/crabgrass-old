Given /Navigation exists/ do
   @nav = Navigation.new
end

When /I am navigating from the root of the menu structure/ do
  if @nav.nil?
    raise "No instance variable @nav!"
  end
  if @nav.structure.nil?
    raise "No structure in @nav!"
  end
  @submenu = @nav.structure
end

Then /show the current navigation submenu/ do
  puts @submenu.inspect
end
