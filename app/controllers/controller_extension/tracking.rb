module ControllerExtension::Tracking
:
  def track(options={})
    Tracking.delayed_insert(
      {:current_user => current_user, :group => @group, :user => @user, :action => :view}.merge(options)
    )
  end

end
