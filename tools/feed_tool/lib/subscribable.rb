#ActiveRecord::Base.extend Feedr::Subscribable::ActMethod

class ActiveRecord::Base
  def acts_as_subscribable options={}
    scope = options[:scope] || self
   end
end


module Feedr

  module Subscribable
    
    
    
    module InstanceMethods
      def self.included(base)
        base.extend ClassMethods
        base.instance_eval do
          
          # add filter-code here
          
        end 
      end
      
      #
      # Here we do everything, that must be done, before a page or something else can be send.
      # Examples:
      # - check security settings
      # - encrypt
      # - create obscure link
      # - preparse
      # - deny message creation      
      def to_message
        return Message.create()
      end
      
      def to_message_from_subscription(subs)
        # [TODO] find out, what we might want to do to the message
        # because of the data in the subscription
        return to_message unless  subs.something_that_avoides_creating_a_message?
      end
      
    end
    
    
    
  end

end
