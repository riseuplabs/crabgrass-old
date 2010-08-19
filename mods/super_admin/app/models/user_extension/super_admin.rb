module UserExtension::SuperAdmin

  def self.included(base)
    base.extend(ClassMethods)
    base.instance_eval do
      include InstanceMethods
      alias_method_chain :member_of?, :superadmin
      alias_method_chain :direct_member_of?, :superadmin
      alias_method_chain :friend_of?, :superadmin
      alias_method_chain :peer_of?, :superadmin
      alias_method_chain :may!, :superadmin
      alias_method_chain :may?, :superadmin
    end
  end

  module ClassMethods
    # Removes the superadmins from some user-lists
    def inactive_user_ids
      if Site.current.super_admin_group
        Site.current.super_admin_group.user_ids
      else
        false
      end
    end
  end

  module InstanceMethods
    # Returns true if self is a super admin on site. Defaults to the
    # current site.
    def superadmin?(site=Site.current)
      if site
        self.group_ids.include?(site.super_admin_group_id)
      else
        false
      end
    end

    def member_of_with_superadmin?(group)
      return true if superadmin?
      return member_of_without_superadmin?(group)
    end

    # is the user a direct member of the group?
    def direct_member_of_with_superadmin?(group)
      return true if superadmin?
      return direct_member_of_without_superadmin?(group)
    end

    def friend_of_with_superadmin?(user)
      return true if (superadmin? or user.superadmin?)
      return friend_of_without_superadmin?(user)
    end

    def peer_of_with_superadmin?(user)
      return true if (superadmin? or user.superadmin?)
      return peer_of_without_superadmin?(user)
    end

    def may_with_superadmin!(perm, object)
      return true if superadmin?
      return may_without_superadmin!(perm, object)
    end

    def may_with_superadmin?(perm, object)
      return true if superadmin?
      return may_without_superadmin?(perm, object)
    end

  end

end

