class AvatarSweeper < ActionController::Caching::Sweeper
  observe Avatar

  def after_save(record)
    for size in %w(xsmall small medium large xlarge)
      expire_page :controller => 'static', :action => 'avatar', :id => record.id, :size => size
    end
  end

end
