module WallHelper
  def private_corner_link user
    link_to("Private Corner", :controller => 'person', :action => 'show', :id => user.id, :wall => 'private')
  end
  def wall_post(post)
    render(:partial => (post.type == 'StatusPost' ? 
                        'profile/wall_status_post' : 'profile/wall_post'),
           :locals => {:wall_post => post})
  end

end
