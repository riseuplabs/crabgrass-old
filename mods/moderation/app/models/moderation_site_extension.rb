module ModerationSiteExtension

  module ClassMethods
  end

  module InstanceMethods
    # We load the moderation group into Conf as fallback.
    # Unlike for superadmin we do NOT overwrite what is in the database.
    def load_config_with_moderation(site_config)
      set_moderation_group(site_config) if self.moderation_group.nil?
      load_config_without_moderation(site_config)
    end

    def set_moderation_group_id!(site_config)
      if name = site_config['moderation_group']
        self.update_attribute :moderation_group, Group.find_by_name(name)
      end
    end
  end

  def self.add_to_class_definition
    lambda do
      belongs_to :moderation_group, :class_name => "Group"
      alias_method_chain :load_config, :moderation
    end
  end
end

