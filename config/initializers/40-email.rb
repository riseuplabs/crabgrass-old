# Loads action_mailer settings from email.yml
# and turns deliveries on if configuration file is found

filename = File.join(File.dirname(__FILE__), '..', 'email.yml')
if File.file?(filename)
  mailconfig = YAML::load_file(filename)

  if mailconfig.is_a?(Hash) && mailconfig.has_key?(Rails.env)
    # Enable deliveries
    ActionMailer::Base.perform_deliveries = true
    
    mailconfig[Rails.env].each do |k, v|
      v.symbolize_keys! if v.respond_to?(:symbolize_keys!)
      ActionMailer::Base.send("#{k}=", v)
    end
  end
end

if (ActionMailer::Base.delivery_method == :smtp and ActionMailer::Base.smtp_settings[:port] and [587,465].include?(ActionMailer::Base.smtp_settings[:port].to_i))
  require "smtp_tls"
end

