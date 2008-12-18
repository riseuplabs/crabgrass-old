class YuckyController < ApplicationController
  include  ActionView::Helpers::TextHelper # for truncate

  before_filter :login_required
  
  # marks the rateable as yucky!
  def add
    @rateable.ratings.find_or_create_by_user_id(current_user.id).update_attribute(:rating, YUCKY_RATING)
    @rateable.update_attribute(:yuck_count, @rateable.ratings.with_rating(YUCKY_RATING).count) 
    
    case @rateable_type
     when :post
        summary = truncate(@rateable.body,200) + (@rateable.body.size > 200 ? "…" : '')
        url = page_url(@rateable.discussion.page, :only_path => false) + "#posts-#{@rateable.id}"
      when :page
        summary = @rateable.title
        url = page_url(@rateable, :only_path => false)
    end
    
    # Notify the admins that content has been marked as innapropriate
     email_options = {:subject => "Inappropriate content", :body => summary, :url => url, :owner => current_user }
     admins = Group.find(Site.default.super_admin_group_id).users.uniq   
     admins.each do |admin|
      AdminMailer.deliver_notify_inappropriate(admin,email_options)
     end
    
    redirect_to referer
  end

  # removes any yucky marks from the rateable
  def remove
    if rating = @rateable.ratings.by_user(current_user).first
      rating.destroy
      @rateable.update_attribute(:yuck_count, @rateable.ratings.with_rating(YUCKY_RATING).count)
    end
    redirect_to referer
  end

  protected
  
  def authorized?
    # you can't flag your own content as (in)appropriate!
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
    end
  end

  def send_user_notification   
    page = Page.make :private_message, :to => current_user, :from => current_user, :title => 'Your complaint has been noticed!', :body => :inapp_noticifation.t
    page.save
  end

end

