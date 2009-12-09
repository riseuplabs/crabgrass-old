class ChatViewListener < Crabgrass::Hook::ViewListener
  include Singleton

  def chat_message_actions(context)
    message = context[:message]
    if !logged_in?
      return
    elsif message.sender == current_user
      return
    elsif message.level == "sys"
      return
    elsif message.deleted_at
      return content_tag :strong, I18n.t(:deleted)
    else
      #
      # WOW: THIS IS GOING TO BE INCREDIBLY SLOW
      #
      rating = message.ratings.find_by_user_id(current_user.id)
      if rating.nil? or rating.rating != YUCKY_RATING
        if current_user.moderator?
          icon = 'trash'
          link_name = I18n.t(:trash_chat_message)
          confirm = nil
        else
          icon = 'sad_plus'
          link_name = I18n.t(:flag_inappropriate)
          confirm = I18n.t(:confirm_inappropriate_page)
          success = nil
        end
        url = url_for(:controller => 'yucky', :chat_message_id => message.id, :action => :add)
        return link_to_remote_with_icon(
          link_name, {:url => url, :confirm => confirm}, {:icon => icon, :class => 'shy'}
        )
        #content_tag(:span, link, :class => "shy", :id => "flag-#{context[:message].id}"})
      elsif rating.rating == YUCKY_RATING
        url = url_for(:controller => 'yucky', :chat_message_id => message.id, :action => :remove)
        return link = link_to_remote_with_icon(
          I18n.t(:flag_appropriate), {:url => url}, {:icon => 'sad_minus', :class => 'shy'}
        )
        #content_tag(:span, link, {:class => 'small_icon sad_minus_16 shy', :id => "flag-#{context[:message].id}"})
      end
    end
  end

end
