
class PageViewListener < Crabgrass::Hook::ViewListener
  include Singleton

  def page_sidebar_actions(context)
    return unless logged_in?
    return if context[:page].created_by == current_user
    rating = context[:page].ratings.find_by_user_id(current_user.id)
    if rating.nil? or rating.rating != YUCKY_RATING
      link = link_to('flag as inappropriate'[:flag_inappropriate],
        {:controller => 'yucky', :page_id => context[:page].id, :action => 'add'},
        :confirm => "Are you sure this page is inappropriate? Click 'OK' only if you think this is offensive, rude or unkind. A moderator will look at the post soon."[:confirm_inappropriate_page])
      page_sidebar_list(content_tag(:li, link, :class => 'small_icon sad_plus_16'))
    elsif rating.rating == YUCKY_RATING
      link = link_to 'flag as appropriate'[:flag_appropriate],
        :controller => 'yucky', :page_id => context[:page].id, :action => 'remove'
      page_sidebar_list(content_tag(:li, link, :class => 'small_icon sad_minus_16'))
    end
  end

  def post_actions(context)
    return unless logged_in?
    return if context[:post].created_by == current_user
    post = context[:post]
    rating = post.ratings.find_by_user_id(current_user.id)
    if rating.nil? or rating.rating != YUCKY_RATING
      link = link_to_remote_icon('sad_plus',
        :url=>{:controller => 'yucky', :post_id => post.id, :action => 'add'},
        :confirm => 'Are you sure this comment is inappropriate? Click \'yes\' *only if* you think this is offensive, rude or unkind. A moderator will look at the post soon.'[:confirm_inappropriate_comment])
      #link = link_to image_tag('/plugin_assets/moderation/images/face-sad.png'),
      #  :controller => 'yucky', :post_id => post.id, :action => 'add'
    elsif rating.rating == YUCKY_RATING
      link = link_to_remote_icon('sad_minus', :url=>{:controller => 'yucky', :post_id => post.id, :action => 'remove'})
      #link = link_to image_tag('/plugin_assets/moderation/images/face-smile.png'),
      #  :controller => 'yucky', :post_id => post.id, :action => 'remove'
    end
    content_tag :div, link, :class => 'post_action_icon', :style => 'margin-right:22px; display: block'
  end

  def html_head(context)
    stylesheet_link_tag('crabgrass', :plugin => 'moderation')
  end

  private

  def page_sidebar_list(list)
    content_tag :ul, list, :class => 'side_list'
  end

end

