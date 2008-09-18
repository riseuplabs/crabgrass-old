class UserObserver < ActiveRecord::Observer

  def after_save(user)
    Mailer.deliver_forgot_password(user) if user.recently_forgot_password? 
    Mailer.deliver_reset_password(user) if user.recently_reset_password? 
  end

end
