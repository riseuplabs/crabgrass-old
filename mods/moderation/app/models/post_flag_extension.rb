module PostFlagExtension
  def self.add_to_class_definition
    lambda do
      has_many :moderated_flags, :foreign_key => 'foreign_id', :dependent => :destroy
    end
  end
  module InstanceMethods
  end
end
