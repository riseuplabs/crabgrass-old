##
## Allow superadmins to pretend they are a member of every group and the friend
## of every user. They are popular! (but only in their minds).
##

module SuperAdminUserExtension
  module InstanceMethods

    def superadmin?
      self.group_ids.include?(Site.default.super_admin_group_id)
      #(Site.default.super_admins||[]).include?(self.login)
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
      return true if superadmin?
      return friend_of_without_superadmin?(user)
    end

    def peer_of_with_superadmin?(user)
      return true if superadmin?
      return peer_of_without_superadmin?(user)
    end

    def may_with_superadmin!(perm, object)
      return true if superadmin?
      return may_without_superadmin!(perm, object)
    end
  end

  def self.add_to_class_definition
    lambda do
      alias_method_chain :member_of?, :superadmin
      alias_method_chain :direct_member_of?, :superadmin
      alias_method_chain :friend_of?, :superadmin
      alias_method_chain :peer_of?, :superadmin
      alias_method_chain :may!, :superadmin
    end
  end

end



