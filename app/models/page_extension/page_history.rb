module PageExtension::PageHistory
  def self.included(base)
    base.instance_eval do
      has_many :page_history, :dependent => :destroy, :order => "page_histories.created_at desc"
    end
  end

  def marked_as_public?
    self.public_changed? && self.public == true
  end

  def marked_as_private?
    self.public_changed? && self.public == false
  end
end
