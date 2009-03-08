
  # This module enhances the usual UserParticipation or GroupParticipation to use an additional Subscription - model
  # to handle the separation between the participation and all the different options for notification, mails etc.
  module ParticipationExtension::Subscribe

    def self.included(base)
      base.instance_eval do
       belongs_to :subscription    
      end
    end
    
    # returns true, if we notify but don't grant access
    def only_notice?
      true if notice? and !share?
    end
  
  # returns true, if notification should be done
  def notice?
    true if !self.notice.nil?
  end
  
  # returns ture, if there has been set an access level (so the page is physically shared)
  def share?
   true if !self.access.nil? #[1,2,3].include?(self.access)
  end
     
  
  # The following methods are basically to get the values from
  # the subscription, not from the user_participation  
  #
   
  # provides an interface to the subscription
  def watch
    (self.subscription && self.subscription.watch) ? true : false ;
  end
  
  # provides an interface to the subscription
  def watch?
    watch ? true : false;
  end
  
  # provides an interface to the subscription
  def watch= w
    ensure_subscription
    self.subscription.watch = w
  end
  
  # provides an interface to the subscription
  def inbox
    self.subscription ? self.subscription.inbox : false;
  end

  # provides an interface to the subscription
  def notice
    self.subscription ? self.subscription.notice : nil;
  end
  
  # provides an interface to the subscription
  def notice= attr
    ensure_subscription
    self.subscription.update_attribute(:notice,attr)
  end
  
  # provides an interface to the subscription
  def inbox= attr
    ensure_subscription
    self.subscription.update_attribute(:inbox,attr)
  end

  # returns the subscribable
  # [NOTE[ it's the page!
  def subscribable
    return self.page #if self.page.respond_to?(:subscribable?)
  end

  private  
  # just makes sure, that this participation has a subscription before we try to set values here
  def ensure_subscription
    self.subscription = Subscription.create unless self.subscription
    if self.subscription
      return true
    else
      raise "no subscription given"
    end  
  end

end
  
