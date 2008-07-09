# Make engines much less verbose!
if defined? Engines
  Engines.logger.level = Logger::INFO
end

#ActiveRecord::Base.logger.level = Logger::DEBUG
#ActionMailer::Base.logger.level = Logger::DEBUG

