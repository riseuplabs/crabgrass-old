module RequestToJoinUsExtension
  module InstanceMethods
    def may_approve_with_superadmin?(user)
      return true if user.superadmin?
      return may_approve_without_superadmin?(user)
    end
  end

  def self.add_to_class_definition
    lambda do
      alias_method_chain :may_approve?, :superadmin
    end
  end

end

