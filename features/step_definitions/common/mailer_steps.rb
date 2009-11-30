Then /^I should receive an email with (\w+)(:|\s+containing) "([^\"]*)"$/ do |field, op, text|
  equal_op = (op == ":")

  found_matching = false
  values = []
  delivered_emails.each do |email|
    # email.send(:subject)
    value = email.send(field.downcase.to_sym)
    values << value

    if equal_op
      found_matching = (value.to_s == text)
    else
      found_matching = (value.to_s =~ /#{text}/)
    end
  end

  values = values.join("\n")
  assert found_matching, "Expected an email to have #{field}#{op} \"#{text}\". Instead found #{field.pluralize}:\n#{values}\n"
end

Then /^I should receive an email with (\w+)(:|\s+containing) (.*) url$/ do |field, op, page_name|
  path = path_to(page_name)
  Then "I should receive an email with #{field}#{op} \"#{path}\""
end
