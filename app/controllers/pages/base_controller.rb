# super class controller for all page types

class Pages::BaseController < ApplicationController
  layout 'pages'
  in_place_edit_for :page, :title
  
  def show  
    @page.discussion = Discussion.new unless @page.discussion
    @post_paging, @posts = paginate(:posts, :per_page => 25, :order => 'posts.created_at',
       :include => :user, :conditions => ['posts.discussion_id = ?', @page.discussion.id])
    @post = Post.new
  end

  def new
    begin
      if request.get?
        @page = Page.new
        raise 'render'
      elsif request.post?
        if params[:group_name].any?
          group = Group.find_by_name params[:group_name]
          if group.nil?
            message :error => 'no such group'
            raise 'render'
          end
        else
          group = Group.find_by_id params[:group_id]
        end
      
        @page = Page.create( params[:page].merge({:created_by_id => current_user.id}) )
        
        
        #tagging
        @page.tag_with(params[:tag_list])      
        @page.save
       
        unless @page.valid?
          message :object => @page
          raise 'render'
        end
        if group
          GroupParticipation.create(:page_id => @page.id, :group_id => group.id)
          if params[:announce]
            for user in group.users
              UserParticipation.create(:page_id => @page.id, :user_id => user.id)
            end
          end
        else
          UserParticipation.create(:page_id => @page.id, :user_id => current_user.id)
        end
        # success:
        redirect_to :action => 'show', :id => @page
      end
    rescue RuntimeError
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
    #@page = Page.find params[:id]
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
  
  def add_tags
    tags = Tag.parse(params[:new_tags]) + @page.tags.collect{|t|t.name}
    @page.tag_with(tags.uniq.join(' '))
    @page.save
    redirect_to page_url(@page)
  end
  
  #show by tag
  def tagged
 # @page.title = "search by tag"
#    @pages = if tag_name = params[:id]
 #     Tag.find_by_name(tag_name).tagged
    #if tag_name = params[:id]
     # @pages = Tag.find_by_name(tag_name).tagged
    if tag_name = params[:id]
      if Tag.find_by_name(tag_name)
        @pages = Tag.find_by_name(tag_name).tagged
      end
    end
  end

  protected
  
  def breadcrumbs
    return unless params[:id] and @page = Page.find_by_id(params[:id])
    if params[:from]
      if logged_in? and params[:from] == 'people' and params[:from_id] == current_user.to_param
        add_crumb 'me', me_url
      else
        add_crumb params[:from], url_for(:controller => params[:from])
        if params[:from_id]
          if params[:from] == 'groups'
            group = Group.find_by_id(params[:from_id])
            text = group.name if group
          elsif params[:from] == 'people'
            text = params[:from_id]
          end
          if text
            add_crumb text, url_for(:controller => params[:from], :id => params[:from_id], :action => 'show')
          end
        end
      end
    elsif @page
      # figure out the first group or first user, and use that for breadcrumb.
      if @page.groups.any?
        add_crumb 'groups', groups_url
        group = @page.groups.first
        add_crumb group.name, groups_url(:action => 'show', :id => group)
      elsif @page.created_by
        add_crumb 'people', people_url
        user = @page.created_by
        add_crumb user.login, people_url(:action => 'show', :id => user)
      end
    end
    # this is silly
    add_crumb @page.title, request.request_uri #temporarily commented out. jb.
  end
  
end
