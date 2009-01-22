##
## Avatars are the little icons used for users and groups.
##

class AvatarsController < ActionController::Base
  session :off
  caches_page :show

#  include ActionView::Helpers::TagHelper
#  include ErrorHelper

  def create 
    unless params[:image]
      flash[:error] = "no image uploaded"
      render(:nothing => true, :layout => true)
      return
    end
    group = Group.find params[:group_id] if params[:group_id]
    user  = User.find params[:user_id] if params[:user_id]
    thing = group || user
    if thing.avatar
      for size in %w(xsmall small medium large xlarge)
        expire_page :controller => 'avatars', :action => 'show', :id => thing.avatar.id, :size => size
      end
      thing.avatar.image_file = params[:image][:image_file]
      thing.avatar.save!
    else
      avatar = Avatar.create(params[:image])
      thing.avatar = avatar
    end
    thing.save! # make sure thing.updated_at has been updated.
    redirect_to params[:redirect]
  #rescue Exception => exc
  #  flash_message_now :exception => exc
  end

  def show
    @image = Avatar.find_by_id params[:id]
    if @image.nil?
      size = Avatar.pixels(params[:size])
      size.sub!(/^\d\dx/,'')
      filename = "#{File.dirname(__FILE__)}/../../public/images/default/#{size}.jpg"
      send_data(IO.read(filename), :type => 'image/jpeg', :disposition => 'inline')
    else
      render :template => 'avatars/show.jpg.flexi'
    end
  end

end
