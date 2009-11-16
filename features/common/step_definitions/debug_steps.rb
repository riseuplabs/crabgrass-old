Then /^wait$/ do
  sleep 0.25
  puts response.body
  sleep
end

Then /^print response$/ do
  puts response.body
end