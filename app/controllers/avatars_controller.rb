#
# expire_page avatar_url(:id => @avatar)
#

class AvatarsController < ApplicationController
  
  caches_page :show  
 
  def create 
    group = Group.find params[:group_id] if params[:group_id]
    user  = User.find params[:user_id] if params[:user_id]
    thing = group || user
    avatar = Avatar.create(:data => params[:image][:data])
    if thing.avatar
      for size in %w(xsmall small medium large xlarge)
        expire_page avatar_url(:id => avatar, :size => size)
      end
      thing.avatar.destroy
    end
    thing.avatar = avatar
    thing.save
    redirect_to params[:redirect]
  end
    
  def show
    image = Avatar.find_by_id params[:id]
    if image.nil?
      size = Avatar.pixels(params[:size])
      size.sub!(/^\d\dx/,'')
      filename = "#{File.dirname(__FILE__)}/../../public/images/default/#{size}.jpg"
      send_data(IO.read(filename), :type => 'image/jpeg', :disposition => 'inline')
    else
      image.resize! :size => Avatar.pixels(params[:size])
      render_flex_image(image)
    end
  end
  
end
