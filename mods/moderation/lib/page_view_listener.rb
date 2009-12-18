
class PageViewListener < Crabgrass::Hook::ViewListener
  include Singleton

  def page_sidebar_actions(context)
    return unless logged_in?
    return if context[:page].created_by == current_user
    if context[:page].moderated_flags.find_by_user_id(current_user.id)
      link = link_to I18n.t(:flag_appropriate),
        :controller => 'base_page/yucky', :page_id => context[:page].id, :action => 'remove'
      page_sidebar_list(content_tag(:li, link, :class => 'small_icon sad_minus_16'))
    #OLD: elsif rating.rating == YUCKY_RATING
    else
      link = popup_line(:name => 'yucky', :label => I18n.t(:flag_inappropriate), :class => 'small_icon sad_plus_16', :controller => 'yucky', :page_id => context[:page].id, :show_popup => 'show_add')
      page_sidebar_list(link)
    end
  end

  def post_actions(context)
    return unless logged_in?
    return if context[:post].created_by == current_user
    post = context[:post]
    #rating = post.ratings.find_by_user_id(current_user.id)
    #if rating.nil? or rating.rating != YUCKY_RATING
    unless context[:post].moderated_flags.find_by_user_id(current_user.id)
      popup_url = url_for({
        :controller => '/base_page/yucky',
        :action => 'show_add',
        :popup => true,
        :post_id => post.id,
        :page_id => context[:page].id
      })
      link = link_to_modal('',{:url => popup_url, :icon => 'sad_plus',:title=>I18n.t(:flag_inappropriate)}, {:class=>'small_icon_button'})
    #elsif rating.rating == YUCKY_RATING
    else
      link = link_to_remote_icon('sad_minus', :url=>{:controller => 'base_page/yucky', :post_id => post.id, :action => 'remove'})
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

