

# Stores a collection of items, that 
# (1) a user can subscribe to
# (2) a user actually did subscribe to
#
# The data comes from subscribable, which is a mixin, that separates various page
# types or whatever you want to be subscribable.
#
# Feed is one place, the delivery of mails to the recipients (subscribers) can be started
#
# migration  
=begin
class CreateFeeds < ActiveRecord::Migration
  def self.up
    create_table :feeds do |t|
      t.integer :subscribable_id
      t.string :subscribable_type
    end
  end

  def self.down
   drop_table :feeds
  end

end
=end
class Feed < ActiveRecord::Base
  
  # this can contain, what ever has been made subscribable
  belongs_to :subscribable, :polymorphic => true

  
  # delivers everything that's recent in this feed
  # 
  # NOTE see Subscribable#to_message_from_subscription
  # it returns a new Message-object that is plain enough
  # to be handled from a worker, that' doesn't want to know
  # anything about crabgrass' internals
  #
  def deliver
    items = self.subscribable.get_new_items
    messages = []
    self.subscribable.subscriptions.each do |subscription|
      messages << self.subscribable.to_message_from_subscription(subscription)
    end
  end
  
  

# is this nighly bullshit? or might there be a fine note of usable information in this
# for sure righteously commented out
=begin  
  # delivers everything for a given list of subscriptions
  def deliver_for_subscriptions(subscriptions=[])
    messages = {}
    subscriptions.each do |subscription|
      # we know, that we only have subscriptions that should be handled by now
      items = subscription.subscribable.get_new_subscribable_items
      items.each do |item|
        #     messages[item.to_sym] = {:recipient => subscription.participant, :security_options => subscription.security_options, :protocols => subscription.protocols}
        messages[item.to_sym] = Message.new(:recipients=> subscription.participant, :security_options => subscription.security_options, :protocols => subscription.protocols)
      end
        
      items = []
      messages.each do |k,v|
        items << k.to_mail_with_options(v)
        # adds the body to v and creates an array of message - objects with the body and the options
      end
        
    end
  end
  
=end  
    
end
