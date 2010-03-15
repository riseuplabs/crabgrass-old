module Admin::SuperPermission
  def may_super?
    logged_in? && current_user.superadmin?
  end

  alias_method :may_become_account?, :may_super?
  %w(index show new edit create update destroy).each do |action|
    %w(users groups email_blasts memberships).each do |controller|
      alias_method "may_#{action}_#{controller}?".intern, :may_super?
    end
  end
end
