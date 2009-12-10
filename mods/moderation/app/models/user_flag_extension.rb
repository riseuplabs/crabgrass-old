module UserFlagExtension
  def self.add_to_class_definition
    lambda do
      has_many :moderated_pages, :dependent => :destroy
      has_many :moderated_posts, :dependent => :destroy
    end
  end
  module InstanceMethods 
    def find_flagged_page_by_id(foreign_id)
      self.moderated_pages.find(:all, :conditions => ['foreign_id = ?', foreign_id])
    end
    def find_flagged_post_by_id(foreign_id)
      self.moderated_posts.find(:all, :conditions => ['foreign_id = ?', foreign_id])
    end
  end
end
