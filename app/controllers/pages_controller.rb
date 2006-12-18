
class PagesController < ApplicationController

  in_place_edit_for :page, :title
  
  def show
    @page = Page.find params[:id]
    #update_last_seen_at
    #(session[:topics] ||= {})[@topic.id] = Time.now.utc if logged_in?
    
    @page.discussion = Discussion.new unless @page.discussion
    @post_paging, @posts = paginate(:posts, :per_page => 25, :order => 'posts.created_at',
       :include => :user, :conditions => ['posts.discussion_id = ?', @page.discussion.id])
    @post = Post.new
  end

  def new
    if request.post?
      @page = Page.create(params[:page])
      if @page.valid?
        if params[:group_id]
          GroupParticipation.create(:page_id => @page.id, :group_id => params[:group_id])
        end
        UserParticipation.create(:page_id => @page.id, :user_id => current_user.id)
        redirect_to :action => 'show', :id => @page
      else
        message :object => @page
      end
    else
      @page = Page.new
      render :action => 'new', :layout => 'application'
    end
  end
  
  def destroy
    if request.post?
      Page.find(params[:id]).destroy
      redirect_to :controller => 'me'
    end
  end
  
  def add
    @page = Page.find params[:id]
    if params[:commit] == 'add group'
      group = Group.find_by_name params[:name]
      if group
        GroupParticipation.create(:page_id => @page.id, :group_id => group.id)
      else
        message :error => 'group not found', :later => 1
      end
      
    elsif params[:commit] == 'add user'
      user = User.find_by_login params[:name]
      if user
        UserParticipation.create(:page_id => @page.id, :user_id => user.id)
      else
        message :error => 'user not found', :later => 1
      end
    end
    redirect_to :action => 'show', :id => @page
  end
  
end
