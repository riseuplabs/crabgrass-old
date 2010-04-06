Then /^#{capture_model} should receive an email with (\w+)(:|\s+containing) "([^\"]*)"$/ do |user, field, op, text|
  # option (a) ... with subject: "Subject String"
  # option (b) ... with subject containing "tring"
  # equal_op true means option (a)
  equal_op = (op == ":")

  user = model(user)

  found_matching = false
  values = []
  delivered_emails.each do |email|
    # only check emails addressed to this user
    next unless email.to.include?(user.email)
    # email.send(:subject)
    value = email.send(field.downcase.to_sym)
    values << value

    if equal_op
      found_matching = (value.to_s == text)
    else
      found_matching = (value.to_s =~ /#{text}/)
    end

    break if found_matching
  end

  values = values.join("\n")
  assert found_matching, "Expected an email to <#{user.email}> to have #{field}#{op} \"#{text}\". Instead found #{field.pluralize}:\n#{values}\n"
end

Then /^I should receive an email with (\w+)(:|\s+containing) (.*) url$/ do |field, op, page_name|
  path = path_to(page_name)
  Then "I should receive an email with #{field}#{op} \"#{path}\""
end
