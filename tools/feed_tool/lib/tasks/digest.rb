task(:handle_digest => :environment) { ((Time.now.wday == DIGEST_DAY) ? Message.weekly : Message.daily).each { |msg| msg.deliver} }

