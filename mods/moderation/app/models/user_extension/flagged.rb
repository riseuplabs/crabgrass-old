module UserExtension::Flagged
  def self.add_to_class_definition
    lambda do
      has_many :moderated_pages, :dependent => :destroy
    end
  end
 
  def find_flagged(foreign_id)
    self.moderated_pages.find(:all, :conditions => ['foreign_id = ?', foreign_id])
  end
end
