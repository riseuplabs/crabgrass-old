module PageFlagExtension
  def self.add_to_class_definition
    lambda do
      has_many :moderated_pages, :foreign_key => 'foreign_key', :dependent => :destroy
    end
  end
  module InstanceMethods 
  end
end
