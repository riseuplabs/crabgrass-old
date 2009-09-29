class ChatFlagController < YuckyController

  permissions 'admin/moderation'
  permissions 'posts'

  before_filter :login_required

  def show_add
    form_url = {:action=>'add',:message_id=>params[:message_id]}
    render :partial=>'base_page/yucky/show_add_popup', :locals=>{:form_url=>form_url}
  end

  # marks the rateable as yucky!
  def add
    #if params[:flag]
      add_chat_message
    #end
  end

  def trash
    @flag.add
    ModeratedChatMessage.trash(@flag.foreign_id)
    @flag.trash_chat_message
  end

  # removes any yucky marks from the rateable
  def remove
    if rating = @rateable.ratings.by_user(current_user).first
      rating.destroy
      @rateable.update_attribute(:yuck_count, @rateable.ratings.with_rating(YUCKY_RATING).count)
    end
    remove_chat_message
  end

  protected

  def add_chat_message
    @flag.add
    summary = @rateable.content
    date = @rateable.created_at
    url = "/chat/archive/"
    url += @rateable.channel.name
    url += "/date/#{date.year}-#{date.month}-#{date.day}##{@flag.chat_message.id}"
    send_moderation_notice(url, summary)
    render :update do |page|
      @message = @flag.chat_message
      page.replace_html dom_id(@message), :partial => 'chat/message', :object => @message
    end
  end

  def remove_chat_message
    render :update do |page|
      @message = @flag.chatmessage
      @flag.destroy
      page.replace_html dom_id(@message), :partial => 'chat/message', :object => @message
    end
  end

  prepend_before_filter :fetch_rateable
  def fetch_rateable
    @flag = ModeratedChatMessage.find_by_foreign_id(params[:chat_message_id]) || ModeratedChatMessage.new(:foreign_id=>params[:chat_message_id], :user_id => current_user.id)
    @rateable = @flag.chat_message
  end

end

