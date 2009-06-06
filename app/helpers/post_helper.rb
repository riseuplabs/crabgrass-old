module PostHelper

  def post_pagination_links
    content_tag(:tr, content_tag(:td, pagination_links(@posts, :param_name => 'posts'), :colspan => 2)) if @posts.any?
  end

  def edit_post_action(post)
    return unless may_edit_posts?
    content_tag :div, :style=>'display: block', :class=>'post_action_icon' do
      link_to_remote_icon('pencil', {:url => {:controller => 'posts', :action => 'edit', :id => post.id}})
    end
  end

  def star_post_action(post)
    return unless may_twinkle_posts?
    content_tag :div, :class=>'post_action_icon' do
      if !post.starred_by?(current_user)
        link_to_remote_icon('star_plus', :url=>{:controller=>'posts', :action=>'twinkle', :id=>post.id})
      else
        link_to_remote_icon('star_minus', :url=>{:controller=>'posts', :action=>'untwinkle', :id=>post.id})
      end
    end
  end
end
