class BasePage::YuckyController < BasePage::SidebarController

  permissions 'admin/moderation'
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
      @flag.add(current_user.id, {:reason=>params[:reason],:comment=>params[:comment]}) unless @flag.nil? 
    end
    close_popup
  end

  def remove
    @flag.remove(current_user)
    if params[:post_id]
      render :update do |page|
        page.replace_html "post-body-#{@post.id}", :partial => 'posts/post_body', :locals => {:post => @post}
      end
    elsif params[:page_id]
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
      @flag = params[:moderated_id] ? ModeratedPost.find_by_id(params[:moderated_id]) : ModeratedPost.new(:foreign_id => params[:post_id])
      @post = Post.find_by_id(params[:post_id])
      @flag.foreign = @post
    elsif params[:page_id]
      @flag = params[:moderated_id] ? ModeratedPage.find_by_id(params[:moderated_id]) : ModeratedPage.new(:foreign_id => params[:page_id])
      @flag.foreign = Page.find_by_id(params[:page_id])
    else
      return false
    end
  end

end

