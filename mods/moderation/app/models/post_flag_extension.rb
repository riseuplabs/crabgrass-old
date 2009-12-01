module PostFlagExtension
  def self.add_to_class_definition
    lambda do
      has_many :moderated_flags, :as => :flagged, :dependent => :destroy
    end
  end
  module InstanceMethods
  end
end
