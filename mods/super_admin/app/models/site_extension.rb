module SiteExtension

  module ClassMethods
  end

  module InstanceMethods
  end

  def self.add_to_class_definition
    lambda do
      belongs_to :super_admin_group, :class_name => "Group"
    end
  end
end

