Then /^wait$/ do
  sleep 0.25
  puts response.try.body || $browser.try.text
  sleep
end

Then /^print response$/ do
  puts response.body
end

Then /^debug$/ do
  require 'ruby-debug';debugger;1-1
end