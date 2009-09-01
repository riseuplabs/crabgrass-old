class YuckyController < ApplicationController
  include  ActionView::Helpers::TextHelper # for truncate

  permissions 'admin/moderation'
  permissions 'posts'

  before_filter :login_required

  # marks the rateable as yucky!
  def add
    @rateable.ratings.find_or_create_by_user_id(current_user.id).update_attribute(:rating, YUCKY_RATING)
    @rateable.update_attribute(:yuck_count, @rateable.ratings.with_rating(YUCKY_RATING).count)

    case @rateable_type
      when :post; add_post
      when :page; add_page
      when :chat_message; add_chat_message
    end
  end

  # removes any yucky marks from the rateable
  def remove
    if rating = @rateable.ratings.by_user(current_user).first
      rating.destroy
      @rateable.update_attribute(:yuck_count, @rateable.ratings.with_rating(YUCKY_RATING).count)
    end
    case @rateable_type
      when :post; remove_post
      when :page; remove_page
      when :chat_message; remove_chat_message
    end
  end

  protected

  def add_page
    summary = @rateable.title
    url = page_url(@rateable, :only_path => false)
    send_moderation_notice(url, summary)
    redirect_to referer
  end

  def add_post
    summary = truncate(@rateable.body,400) + (@rateable.body.size > 400 ? "…" : '')
    url = page_url(@rateable.discussion.page, :only_path => false) + "#posts-#{@rateable.id}"
    send_moderation_notice(url, summary)

    render :update do |page|
      page.replace_html "post-body-#{@rateable.id}", :partial => 'posts/post_body', :locals => {:post => @rateable}
    end
  end

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

  def remove_page
    redirect_to referer
  end

  def remove_post
    render :update do |page|
      page.replace_html "post-body-#{@rateable.id}", :partial => 'posts/post_body', :locals => {:post => @rateable}
    end
  end

  def remove_chat_message
    render :update do |page|
      @message = @rateable
      page.replace_html dom_id(@message), :partial => 'chat/message', :object => @message
    end
  end

   # Notify the admins that content has been marked as innapropriate
  def send_moderation_notice(url, summary)
    email_options = mailer_options.merge({:subject => "Inappropriate content".t, :body => summary, :url => url, :owner => current_user})
    admins = current_site.super_admin_group.users
    admins.each do |admin|
      AdminMailer.deliver_notify_inappropriate(admin, email_options)
    end
  end

  def authorized?
    @rateable.created_by != current_user
  end

  prepend_before_filter :fetch_rateable
  def fetch_rateable
    if params[:page_id]
      @rateable = Page.find(params[:page_id])
      @rateable_type = :page
    elsif params[:post_id]
      @rateable = Post.find(params[:post_id])
      @rateable_type = :post
    elsif params[:chat_message_id]
      @rateable = ChatMessage.find(params[:chat_message_id])
      @rateable_type = :chat_message
    end
  end

  #def send_user_notification
  #  page = Page.make :private_message, :to => current_user, :from => current_user, :title => 'Your complaint has been noticed!', :body => :inapp_noticifation.t
  #  page.save
  #end

end

