# Loads action_mailer settings from crabgrass.RAILS_ENV.yml
# and turns deliveries on if configuration file is found

if Conf.email
  mailconfig = Conf.email

  if mailconfig.is_a?(Hash)
    # Enable deliveries
    ActionMailer::Base.perform_deliveries = true

    mailconfig.each do |k, v|
      v.symbolize_keys! if v.respond_to?(:symbolize_keys!)
      ActionMailer::Base.send("#{k}=", v)
    end
  end
end

if (ActionMailer::Base.delivery_method == :smtp and ActionMailer::Base.smtp_settings[:port] and [587,465].include?(ActionMailer::Base.smtp_settings[:port].to_i))
  require "smtp_tls"
end

