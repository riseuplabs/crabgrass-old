class StaticController < ActionController::Base

  session :off
  caches_page :avatar

  def avatar
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
