config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = false

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# set this to true to play with view caching:
config.action_controller.perform_caching             = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.perform_deliveries = true
config.action_mailer.delivery_method = :test


ASSET_PRIVATE_STORAGE = "#{RAILS_ROOT}/tmp/private_assets"
ASSET_PUBLIC_STORAGE  = "#{RAILS_ROOT}/tmp/public_assets"

MIN_PASSWORD_STRENGTH = 0

TEST_EMAIL_FILE = RAILS_ROOT + "/tmp/test_emails"

class ActionMailer::Base
  def perform_delivery_test(mail)
    old_emails = begin YAML.load_file(TEST_EMAIL_FILE) rescue [] end
    this_email = {}

    fields = [:to, :from, :cc, :bcc, :subject, :body]
    fields.each do |field|
      # this_email[:cc] = ["some@host.com", "other@newhost.org"]
      # this_email[:body] = "hello there"
      this_email[field] = mail.send(field)
    end

    old_emails << this_email
    File.open(TEST_EMAIL_FILE, "w") {|file| file.write(YAML.dump(old_emails))}
  end
end


# however, rails engines are way too verbose, so set engines logging to info:
if defined? Engines
  Engines.logger = ActiveSupport::BufferedLogger.new(config.log_path)
  Engines.logger.level = Logger::INFO
end

