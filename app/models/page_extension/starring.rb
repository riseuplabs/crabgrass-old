module PageExtension::Starring
  def self.included(base)
    base.extend ClassMethods
    base.send(:include, InstanceMethods)
  end


  # Helps with getting and setting static content
  module ClassMethods

    # finds the pages with the most stars
    # use options[:at_least] to pass the number of stars required
    # use options[:limit] to limitate them to a number of Integer
    # use options[:order] to override default order DESC
    def find_by_stars options={}
      limit = options[:limit] || nil
      order = options[:order] || "stars_count DESC"
      at_least = options[:at_least] || 0
      find :all, :order => order, :limit => limit, :conditions => ["stars_count >= ?", at_least]
    end

    def update_all_stars
      self.find(:all).each do |page|
        correct_stars = page.get_stars
        page.update_attribute(:stars_count, correct_stars) if correct_stars != page.stars
      end
    end

  end

  module InstanceMethods

    # gets the number of stars for one page
    def get_stars
      self.user_participations.count(:all, :conditions => { :star => true})
    end

  end

end
