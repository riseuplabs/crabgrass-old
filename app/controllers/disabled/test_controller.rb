
class TestController < ActionController::Base

  def page
    #render :text => ActiveSupport::Dependencies.load_once_paths.inspect
    render :text => AssetPage.new.flag.inspect
  end


end

