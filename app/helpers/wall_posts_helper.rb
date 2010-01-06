module WallPostsHelper
  def display_post(post)
    render(:partial => 'wall_posts/post', :locals => {:post => post})
  end

  def delete_post(post)
    if may_destroy_public_messages?(@user,post)
      if current_user.wall_discussion.id == post.discussion.id
        link_to_icon('minus', my_public_message_url(post), :method => :delete, :title => I18n.t(:delete), :class => 'shy')
      elsif current_user.id == post.user_id
        link_to_icon('minus', person_message_url(@user, post), :method => :delete, :title => I18n.t(:delete), :class => 'shy')
      end
    end
  end

end
