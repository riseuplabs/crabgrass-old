module GroupExtension
  module Featured

    def self.included(base)
      base.send :include, InstanceMethods
      base.instance_eval do

        has_many :featured_pages, :through => :participations, :conditions => ["`group_participations`.static = ?", true], :source => :page

      end
    end

    # goes into Group
    module InstanceMethods


      ##
      ## DISABLED
      ## we don't need expiration for now
      ##

      # # just alias map
      # def featured_pages
        # find_static.map(&:id)
      # end


      # # gets all the featured pages for one group, using group-context
      # def find_static options={}
      #   ret = []
      #   options = options.merge(:include => :page, :order => "pages.updated_at DESC")
      #   self.participations.find_all_by_static(true, options).each {|p|
      #
      #     if !p.static_expires?
      #       ret << p.page
      #     else
      #       p.unstatic!
      #     end
      #   }
      #   ret
      # end
      #
      # # gets all featured pages that have been expired
      # def find_expired options={}
      #   ret = []
      #   options = options.merge(:include => :page, :order => "pages.updated_at DESC")
      #   since = options.delete(:since) if options[:since]
      #   since ? since = Time.now.to_date = since.days : since = Time.now.to_date ;
      #   self.participations.find_all_by_static_expired(true, :conditions => ["static_expires <= ?", since], :order => ["static_expires DESC"]).each do |p|
      #     ret << p.page
      #   end
      #   ret
      # end
      #
      # # gets all the pages that are not static and not expired
      # def find_unstatic options={}
      #   ret = []
      #   options = options.merge(:include => :page, :order => "pages.updated_at DESC")
      #   expired = self.find_expired
      #   self.participations.find_all_by_static(false,options).each do |p|
      #     ret << p.page unless expired && expired.include?(p.page)
      #   end
      #   ret
      # end
    end
  end
end

module GroupParticipationExtension
  module Featured

    def self.included(base)
      # base.extend ClassMethods
      base.send :include, InstanceMethods
      base.instance_eval do |t|
        ##
        ## NAMED SCOPES
        ##
        named_scope :featured, :conditions => {:static => true}
        named_scope :with_pages, :include => :page
      end
    end

    module InstanceMethods

      def feature!
        # find and increment the higest sibling position
        position = self.group.participations.maximum(:featured_position).to_i + 1
        self.update_attributes!({:static => true, :featured_position => position})
      end

      def unfeature!
        self.update_attributes!({:static => false, :featured_position => nil})
      end


      ##
      ## DISABLED
      ## disabling automatic expiration for now
      ##

      # # sets a page to static till date comes
      # def static! date=nil
      #   self.static = true
      #   self.static_expires = date || (Time.now.to_date + 5.days)
      #   self.static_expired = false
      #   self.save!
      # end
      #
      # def static_can_expire?
      #   raise_if_not_static
      #   !self.static_expires.nil?
      # end
      #
      # # finds out if page-static expires
      # def static_expires?
      #   raise_if_not_static
      #   return false unless static_can_expire?
      #   true if (self.static_expires.to_date+1.day) <= Time.now.to_date
      # end
      #
      # # finds out if a page has expired before
      # def static_expired?
      #   raise_if_not_static
      #   true if self.static_expired == true
      # end
      #
      # # sets page to unstatic mode
      # def unstatic!
      #   raise_if_not_static
      #   self.static = false
      #   self.static_expired = true
      #   self.save!
      # end

      ##
      ## DISABLED
      ## disabling automatic expiration for now
      ##

      # private
      #
      # def raise_if_not_static
      #   if self.static != true
      #     raise ArgumentError.new(I18n.t(:page_is_not_static))
      #   end
      # end
    end

  end
end
