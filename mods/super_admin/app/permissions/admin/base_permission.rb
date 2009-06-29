module Admin::BasePermission
  def self.included(base)
    base.send(:include, Admin::SuperPermission)
  end
end
