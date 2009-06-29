module Admin::SuperPermission
  def may_super?
    if session[:admin]
      # if session[:admin] is set, then a superadmin user has assumed the identity
      # of a regular user and is now returning to the admin panel. So we restore
      # their actual identity.
      session[:user] = session[:admin]
      session[:admin] = nil
      redirect_to '/admin'
      true
    else
      logged_in? && current_user.superadmin?
    end
  end
  
  alias_method :may_become_account?, :may_super?
  %w(index show new edit create update destroy).each do |action|
    %w(users groups email_blasts memberships).each do |controller|
      alias_method "may_#{action}_#{controller}?".intern, :may_super?
    end
  end
end
