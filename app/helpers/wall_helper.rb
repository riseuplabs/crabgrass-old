module WallHelper

  def private_corner_link user
    link_to("Private Corner", :controller => 'person', :action => 'show', :id => user.id, :wall => 'private')
  end

  def wall_post(post)
    render(:partial => (post.type == 'StatusPost' ? 
                        'profile/wall_status_post' : 'profile/wall_post'),
           :locals => {:wall_post => post})
  end
  
  def delete_wall_post(post)
    if current_user.discussion.id == post.discussion.id
      link_to("Delete Post"[:delete_post], url_for(:controller => '/me/dashboard', :action => 'delete_wall_post', :id => post.id ))
    end
  end

end
