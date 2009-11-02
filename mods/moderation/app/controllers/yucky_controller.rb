class YuckyController < ApplicationController
  include  ActionView::Helpers::TextHelper # for truncate
  include ModerationNotice

  permissions 'admin/moderation'
  permissions 'posts'

  before_filter :login_required
  permissions 'posts'
  # marks the rateable as yucky!
  def add
    @rateable.ratings.find_or_create_by_user_id(current_user.id).update_attribute(:rating, YUCKY_RATING)
    @rateable.update_attribute(:yuck_count, @rateable.ratings.with_rating(YUCKY_RATING).count)

    add_chat_message
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
    @rateable.update_attribute(:deleted_at, Time.now) if current_user.moderator?
    summary = @rateable.content
    date = @rateable.created_at
    url = "/chat/archive/"
    url += @rateable.channel.name
    url += "/date/#{date.year}-#{date.month}-#{date.day}##{@rateable.id}"
    send_moderation_notice(url, summary)
    render :update do |page|
      @message = @rateable
      page.replace_html dom_id(@message), :partial => 'chat/message', :object => @message
    end
  end

  def remove_chat_message
    render :update do |page|
      @message = @rateable
      page.replace_html dom_id(@message), :partial => 'chat/message', :object => @message
    end
  end

  def authorized?
    @rateable.created_by != current_user
  end

  prepend_before_filter :fetch_rateable
  def fetch_rateable
    if params[:page_id]
      return
    elsif params[:post_id]
      return
    elsif params[:chat_message_id]
      @rateable = ChatMessage.find(params[:chat_message_id])
      @rateable_type = :chat_message
    end
  end
end

