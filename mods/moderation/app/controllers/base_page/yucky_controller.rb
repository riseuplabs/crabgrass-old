class BasePage::YuckyController < ApplicationController
  include ModerationNotice

  helper 'base_page'

  permissions 'admin/moderation'
  permissions 'flag'
  permissions 'posts'

  before_filter :login_required

  def show_add
    if params[:post_id]
      form_url = {:controller => 'yucky', :action => 'add', :post_id => params[:post_id], :page_id => params[:page_id] }
    elsif params[:page_id]
      form_url = {:controller => 'yucky', :action => 'add', :page_id => params[:page_id] }
    end
    render :partial => 'base_page/yucky/show_add_popup', :locals => {:form_url => form_url}
  end

  def add
    if params[:flag]
      @flag.add({:reason=>params[:reason],:comment=>params[:comment]}) unless @flag.nil? 
      if params[:post_id]
        summary = truncate(@flag.post.body,400) + (@flag.post.body.size > 400 ? "…" : '')
        url = page_url(@flag.post.discussion.page, :only_path => false) + "#posts-#{@flag.post.id}"
      elsif params[:page_id]
        summary = @flag.page.summary
        url = page_url(@flag.page)
      end
      send_moderation_notice(url, summary)
    end
    close_popup
  end

  def remove
    ### for some reason we update the :yucky_count in the page/post/chat model
    @flag.destroy
    if params[:post_id]
      @flag.post.update_attribute(:yuck_count, ModeratedPage.by_foreign_id(params[:post_id]).count)
      render :update do |page|
        page.replace_html "post-body-#{@post.id}", :partial => 'posts/post_body', :locals => {:post => @post}
      end
    elsif params[:page_id]
      @flag.page.update_attribute(:yuck_count, ModeratedPost.by_foreign_id(params[:page_id]).count)
      redirect_to referer
    end
  end

  def close_popup
    if params[:post_id]
      render :template => '/posts/reset_post'
    elsif params[:page_id]
      render :template => 'base_page/reset_sidebar'
    end
  end

  protected

  prepend_before_filter :fetch_flag
  def fetch_flag
    if params[:post_id]
      @flag = current_user.find_flagged_post_by_id(params[:post_id]).first || ModeratedPost.new(:foreign_id => params[:post_id], :user_id => current_user.id)
      @post = @flag.post #Post.find_by_id(params[:post_id])
      #@flag.foreign ||= @post
    elsif params[:page_id]
      @flag = current_user.find_flagged_page_by_id(params[:page_id]).first || ModeratedPage.new(:foreign_id => params[:page_id], :user_id => current_user.id)
      @page = @flag.page
      #@flag.foreign ||= Page.find_by_id(params[:page_id])
    else
      return false
    end
  end

end

