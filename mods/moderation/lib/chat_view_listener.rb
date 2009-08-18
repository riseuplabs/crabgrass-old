class ChatViewListener < Crabgrass::Hook::ViewListener
  include Singleton

  def chat_message_actions(context)
    return unless logged_in?
    return if context[:message].sender == current_user or context[:message].level == "sys"
    rating = context[:message].ratings.find_by_user_id(current_user.id)
    if rating.nil? or rating.rating != YUCKY_RATING
      url = url_for(:controller => 'yucky',
                    :chat_message_id => context[:message].id,
                    :action => :add)
      link = link_to_remote(:flag_inappropriate.t,
                            :url => url,
                            :confirm => :confirm_inappropriate_page.t)
      content_tag(:span, link, {:class => 'small_icon sad_plus_16 shy', :id => "flag-#{context[:message].id}"})
    elsif rating.rating == YUCKY_RATING
      url = url_for(:controller => 'yucky',
                    :chat_message_id => context[:message].id,
                    :action => :remove)
      link = link_to_remote(:flag_appropriate.t,
                            :url => url,
                            :confirm => :confirm_inappropriate_page.t)
      content_tag(:span, link, {:class => 'small_icon sad_minus_16 shy', :id => "flag-#{context[:message].id}"})
    end
  end
end
