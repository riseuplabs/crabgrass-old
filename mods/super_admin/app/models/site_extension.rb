module SiteExtension

  module ClassMethods
  end

  module InstanceMethods
    # Force the superadmin group to be what is in config file
    # or disable the site.
    def load_config_with_super_admin(site_config)
      load_config_without_super_admin &&
        set_admin_group(site_config['admin_group'])
    end

    def set_admin_group(name)
      if admin_group = Group.find_by_name(name)
        self.update_attribute :super_admin_group_id, admin_group.id
      else
        puts "ERROR (%s): super admin group '%s' not found! (skipping site)" %
        [Conf.configuration_filename, name]
      end
    end
  end

  def self.add_to_class_definition
    lambda do
      belongs_to :super_admin_group, :class_name => "Group"
      alias_method_chain :load_config, :super_admin
    end
  end
end

