class Me::AvatarsController < Me::BaseController

  def destroy
    @user.kill_avatar
    render :text => avatar_for(@user,"x-large")
  end

end
