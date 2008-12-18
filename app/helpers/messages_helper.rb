module MessagesHelper

  def display_post(post)
    render(:partial => (post.type == 'StatusPost' ? 'messages/status_post' : 'messages/post'), :locals => {:post => post})
  end
  
  def delete_post(post)
    if current_user.discussion.id == post.discussion.id
      link_to("Delete Post"[:delete_post], url_for(:controller => '/messages', :action => 'destroy', :id => post.id, :user => current_user.login ), :method => 'post')
    end
  end

end
