#
# expire_page avatar_url(:id => @avatar)
#

class AvatarsController < ApplicationController
  
#  def new
#    if request.post?
#      img = Avatar.create(:data => params[:image][:data], :user_id => params[:user_id])
#      redirect_to :controller => 'me', :action => 'edit'
#    end
#  end  
  
  def show
    image = Avatar.find :first, :conditions => ['viewable_id = ? AND viewable_type = ?', params[:viewable_id], params[:viewable_type]]
    if image.nil?
      image = Avatar.find :first
    end
    return render(:text => 'image not found', :status => 400) unless image
    size = Avatar.pixels(params[:size].sub(/\.(jpg|png)$/,''))
    if size
      image.resize!(:size => size)
    end
    render_flex_image(image)
  end
  
end
