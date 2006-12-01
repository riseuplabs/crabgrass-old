class PictureSweeper < ActionController::Caching::Sweeper
  observe Picture
  
  def after_save(record)
    expire_page(:controller => 'picture', :action => 'picture', :id => record)
    expire_page(:controller => 'picture', :action => 'thumb', :id => record)
  end
end
