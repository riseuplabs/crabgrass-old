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
    image = Avatar.find_by_id params[:id]
    if image.nil?
      size = Avatar.pixels(params[:size])
      size.sub!(/^\d\dx/,'')
      send_file "#{File.dirname(__FILE__)}/../../public/images/#{size}/default.png", :type => 'image/png', :disposition => 'inline'
    else
      image.resize! :size => Avatar.pixels(params[:size])
      render_flex_image(image)
    end
  end
  
end
