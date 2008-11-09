module PageExtension::Static
  def self.included(base)
    base.extend ClassMethods
    base.send(:include, InstanceMethods)
  end
  
  
  # Helps with getting and setting static content
  module ClassMethods
    


    # finds static pages
    # pages that should have expired yet will do so now
    # options can be passed as usual
    def find_static options = {}
      pages = find_all_by_static(true, options)
      ret = []
      pages.each do |page|
        if !page.static_expires?
          ret << page
        else
          page.unstatic!
        end
      end
      ret
    end
    
    # finds pages that have expired
    # [NOTE]: only finds things, that have been filtered through find_static as expired before
    def find_expired options={}
      since = options.delete(:since) if options[:since]
      since ? since = Time.now.to_date - since.days : since = Time.now.to_date ;
      find_by_static_expired(:true, :conditions => ["static_expires <= ?", since], :order => ["static_expires DESC"])
    end

    
    # finds the pages with the most stars
    # use options[:at_least] to pass the number of stars required
    # use options[:limit] to limitate them to a number of Integer
    # use options[:order] to override default order DESC
    def find_by_stars options={}
      limit = options[:limit] || nil
      order = options[:order] || "stars DESC"
      at_least = options[:at_least] || 0
      find :all, :order => order, :limit => limit, :conditions => ["stars >= ?", at_least]
    end
    
    def update_all_stars
      self.find(:all).each do |page|
        correct_stars = page.get_stars
        page.update_attribute(:stars, correct_stars) if correct_stars != page.stars
      end
    end
    
  end
  
  module InstanceMethods

    # gets the number of stars for one page
    def get_stars
      self.user_participations.count(:all, :conditions => { :star => true})
    end

    
    # sets a page to static till date comes
    def static! date=nil
      self.static = true
      self.static_expires = date
      self.static_expired = false
      self.save!
    end
    
    def static_can_expire?
      raise_if_not_static
      !self.static_expires.nil?
    end
    
    # finds out if page-static expires
    def static_expires?
      raise_if_not_static
      return false unless static_can_expire?
      true if self.static_expires.to_date <= Time.now.to_date
    end
    
    # finds out if a page has expired before
    def static_expired?
      raise_if_not_static
      true if self.static_expired == true
    end
    
    # sets page to unstatic mode
    def unstatic!
      raise_if_not_static
      self.static = false
      self.static_expired = true
      self.save!
    end
    
    private
    def raise_if_not_static
      if self.static != true
        raise ArgumentError.new("Page is not static")
      end
    end
  end


  module UserParticipationMethods

    def self.included(base)
      base.class_eval do
        after_save :update_stars
      end
    end    
    
    def update_stars
      new_stars_count = page.get_stars
      page.update_attribute(:stars, page.get_stars) unless new_stars_count == page.stars
    end

  end  
  
end
