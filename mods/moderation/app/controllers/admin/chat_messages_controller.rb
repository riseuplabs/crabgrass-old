class Admin::ChatMessagesController < Admin::BaseController
  include  ActionView::Helpers::TextHelper # for truncate

  permissions 'admin/moderation'

  def index
    params[:view] ||= 'new'
    view = params[:view]
    @current_view = view

    if view == 'all'
      options = { :conditions => ["created_at > ?", 1.days.ago.to_s(:db)], :order => 'created_at DESC' }
    elsif view == 'new'
      # all messages that have been flagged as inappropriate have not had any admin action yet.
      options = { :conditions => ['(vetted = ? AND rating = ? AND deleted_at IS NULL)', false, YUCKY_RATING], :joins => :ratings, :order => 'created_at DESC' }
    elsif view == 'vetted'
      # all messages that have been marked as vetted by an admin (and are not deleted)
      options = { :conditions => ['vetted = ? AND deleted_at IS NULL', true], :order => 'created_at DESC' }
    elsif view == 'deleted'
      # list the pages that are 'deleted' by being hidden from view.
      options = { :conditions => ['deleted_at IS NOT NULL'], :order => 'created_at DESC' }
    end
    @messages = ChatMessage.paginate(options.merge(:page => params[:page]))
  end

  # Approves a post by marking :vetted = true
  def approve
    message = ChatMessage.find params[:id]
    message.update_attribute(:vetted, true)
    # get rid of all yucky associated with the message
    message.ratings.destroy_all
    redirect_to :action => 'index', :view => params[:view]
  end

  # Reject a message by setting deleted_at=now, the message will now be 'deleted'(hidden)
  def trash
    message = ChatMessage.find params[:id]
    message.update_attribute(:deleted_at, Time.now)
    redirect_to :action => 'index', :view => params[:view]
  end

  # undelete a message by setting setting deleted_at=false, the message will now be 'undeleted'(unhidden)
  def undelete
    message = ChatMessage.find params[:id]
    message.update_attribute(:deleted_at, nil)
    redirect_to :action => 'index', :view => params[:view]
  end

  def set_active_tab
    @active_tab = :moderation
    @admin_active_tab = 'chat_messages_moderation'
  end

  def authorized?
    may_moderate?
  end
end

