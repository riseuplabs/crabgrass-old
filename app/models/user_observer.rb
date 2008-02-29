class UserObserver < ActiveRecord::Observer

  def after_save(user)
    UserMailer.deliver_forgot_password(user) if user.recently_forgot_password? 
    UserMailer.deliver_reset_password(user) if user.recently_reset_password? 
  end

end
