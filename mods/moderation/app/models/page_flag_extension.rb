module PageFlagExtension
  def self.add_to_class_definition
    lambda do
      has_many :moderated_pages, :foreign_key => 'foreign_id', :dependent => :destroy
    end
  end
  module InstanceMethods
  end
end
