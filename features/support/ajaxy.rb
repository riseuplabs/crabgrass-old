## email simulation
require 'ostruct'
def delivered_emails
  hash_emails = begin YAML.load_file(TEST_EMAIL_FILE) rescue [] end

  # convert to open structs so we can do
  # emails[0].body
  hash_emails.collect {|email| OpenStruct.new(email)}
end

Before do
  DatabaseCleaner.clean_with :truncation
  FileUtils.rm(TEST_EMAIL_FILE) if File.exists?(TEST_EMAIL_FILE)
end

