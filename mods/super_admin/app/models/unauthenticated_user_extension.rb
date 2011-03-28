module UnauthenticatedUserExtension
  def self.include base
    base.instance_eval do
      include InstanceMethods
    end
  end

  module InstanceMethods
    def superadmin?
      false
    end
  end
end

