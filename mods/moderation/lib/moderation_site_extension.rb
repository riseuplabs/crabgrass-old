module ModerationSiteExtension

  module ClassMethods
  end

  module InstanceMethods
  end

  def self.add_to_class_definition
    lambda do
      belongs_to :moderation_group, :class_name => "Group"
    end
  end
end

