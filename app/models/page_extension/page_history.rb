module PageExtension::PageHistory
  def self.included(base)
    base.instance_eval do
      has_many :page_history, :dependent => :destroy
    end
  end

  def star_added?
    self.stars_count_was < self.stars_count ? true : false
  end
  
  def star_removed?
    self.stars_count_was > self.stars_count ? true : false
  end

  def marked_as_public?
    return false if not self.public_changed?
    self.public == true
  end

  def marked_as_private?
    return false if not self.public_changed?
    self.public == false
  end
end
