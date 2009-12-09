class BasePage::YuckyController < BasePage::SidebarController
  include ModerationNotice

  helper 'base_page'

  permissions 'admin/moderation'
  permissions 'flag'
  permissions 'posts'

  before_filter :login_required

  def show_add
    if @post
      form_url = {:controller => 'yucky', :action => 'add', :post_id => @post.id, :page_id => @page.id }
    elsif @page
      form_url = {:controller => 'yucky', :action => 'add', :page_id => @page.id }
    end
    render :partial => 'base_page/yucky/show_add_popup', :locals => {:form_url => form_url}
  end

  def add
    if params[:flag]
      @flag.add({:reason=>params[:reason],:comment=>params[:comment]}) unless @flag.nil?
      if @post
        summary = truncate(@post.body,400)
        url = page_url(@post.discussion.page, :only_path => false) + "#posts-#{@post.id}"
      elsif @page
        summary = @page.summary
        url = page_url(@page)
      end
      send_moderation_notice(url, summary)
    end
    close_popup
  end

  def remove
    ### for some reason we update the :yucky_count in the page/post/chat model
    @flag.destroy
    @flagged.update_attribute(:yuck_count, @flagged.moderated_flags.count)
    if @post
      render :update do |page|
        page.replace_html "post-body-#{@post.id}", :partial => 'posts/post_body', :locals => {:post => @post}
      end
    elsif @page
      redirect_to referer
    end
  end

  def close_popup
    if @post
      render :template => '/posts/reset_post'
    elsif @page
      render :template => 'base_page/reset_sidebar'
    end
  end

  protected

  prepend_before_filter :fetch_flag
  def fetch_flag
    @post = Post.find(params[:post_id]) if params[:post_id]
    @page = Page.find(params[:page_id]) if params[:page_id]
    @flagged = @post || @page
    return false unless @flagged
    @flag = @flagged.moderated_flags.find_by_user_id(current_user.id)
    @flag ||= ModeratedFlag.new(:flagged => @flagged, :user => current_user)
  end

end

