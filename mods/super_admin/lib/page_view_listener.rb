
class PageViewListener < Crabgrass::Hook::ViewListener
  include Singleton

  def page_sidebar_actions(context)
    return unless logged_in?
    return if context[:page].created_by == current_user
    rating = context[:page].ratings.find_by_user_id(current_user.id)
    if rating.nil? or rating.rating != YUCKY_RATING
      link = link_to 'flag as inappropriate'[:flag_inappropriate], 
        :controller => 'yucky', :page_id => context[:page].id, :action => 'add'
      page_sidebar_list(content_tag(:li, link, :class => 'small_icon yuck_icon'))
    elsif rating.rating == YUCKY_RATING
      link = link_to 'flag as appropriate'[:flag_appropriate], 
        :controller => 'yucky', :page_id => context[:page].id, :action => 'remove'
      page_sidebar_list(content_tag(:li, link, :class => 'small_icon unyuck_icon'))
    end
  end
  
  def post_actions(context)
    return unless logged_in?
    return if context[:page].created_by == current_user
    post = context[:post]
    rating = post.ratings.find_by_user_id(current_user.id)
    if rating.nil? or rating.rating != YUCKY_RATING
      link = link_to image_tag('/plugin_assets/super_admin/images/face-sad.png'), 
        :controller => 'yucky', :post_id => post.id, :action => 'add'
    elsif rating.rating == YUCKY_RATING
      link = link_to image_tag('/plugin_assets/super_admin/images/face-smile.png'), 
        :controller => 'yucky', :post_id => post.id, :action => 'remove'
    end
    content_tag :div, link, :class => 'post_action_icon', :style => 'margin-right:22px'
  end

  def html_head(context)
    stylesheet_link_tag('crabgrass', :plugin => 'super_admin') 
  end

  private
 
  def page_sidebar_list(list)
    content_tag :ul, list, :class => 'side_list'
  end

end

