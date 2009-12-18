module UserFlagExtension
  def self.add_to_class_definition
    lambda do
      has_many :moderated_flags, :dependent => :destroy
    end
  end
end
