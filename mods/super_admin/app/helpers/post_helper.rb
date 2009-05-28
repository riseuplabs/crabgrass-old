module PostHelper
  def star_post_action(post)
    return unless logged_in? and post.user_id != current_user.id and current_user.may?(:comment,@page)
    content_tag :div, :style => 'display: block', :class=>'post_action_icon' do
      if !post.starred_by?(current_user)
        link_to_remote_icon('star_plus', :url=>{:controller=>'posts', :action=>'twinkle', :id=>post.id})
      else
        link_to_remote_icon('star_minus', :url=>{:controller=>'posts', :action=>'untwinkle', :id=>post.id})
      end
    end
  end
end
