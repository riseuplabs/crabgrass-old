module MessagesHelper

  def display_post(post)
    render(:partial => 'messages/post', :locals => {:post => post})
  end
  
  def delete_post(post)
    if may_destroy_messages?(@user,@post)
      if current_user.discussion.id == post.discussion.id
        link_to("Delete"[:delete], my_public_message_url(post), :method => :delete)
      elsif current_user.id == post.user_id
        link_to("Delete"[:delete], person_message_url(@user, post), :method => :delete)
      end
    end
  end

end
