# super class controller for all page types

class Tool::BaseController < ApplicationController
  layout 'tool'
  #in_place_edit_for :page, :title
  
  prepend_before_filter :fetch_page
  append_before_filter :login_or_public_page_required
  skip_before_filter :login_required
  append_before_filter :setup_view
  append_after_filter :update_participation
  
  def remove_from_my_pages
    @upart.destroy
    redirect_to from_url(@page)
  end
  
  def add_to_my_pages
    @page.add(current_user)
    redirect_to page_url(@page)
  end
  
  def make_resolved
    @upart.resolved = true
    @upart.save
    redirect_to page_url(@page)
  end
  
  def make_unresolved
    @upart.resolved = false
    @upart.save
    redirect_to page_url(@page)
  end  
  
  def add_star
    @upart.star = true
    @upart.save
    redirect_to page_url(@page)
  end
  
  def remove_star
    @upart.star = false
    @upart.save
    redirect_to page_url(@page)
  end  
  
  def destroy
    if request.post?
      @page.data.destroy if @page.data # can this be in page?
      @page.destroy
    end
    redirect_to from_url
  end

  def access
    @sidebar = false
    if request.post?
      if group_id = params[:remove_group]
        @page.remove(Group.find_by_id(group_id))
      elsif user_id = params[:remove_user]
        @page.remove(User.find_by_id(user_id))
      end
      @page.save
    end
    render :template => 'pages/access'
  end
  
  def title
    return(redirect_to page_url(@page, :action => :show)) unless request.post?
    title = params[:page][:title]
    name = params[:page][:name].nameize
    if name.any?
      pages = Page.find(:all,
        :conditions => ['pages.name = ? and group_participations.group_id IN (?)',name, @page.group_ids],
        :include => :group_participations)
      if pages.any? and pages.first != @page
        message :error => 'That page name is already taken'
        render :action => 'show'
        return
      end
    end
    @page.title = title
    @page.name = name
    if @page.save
      redirect_to page_url(@page, :action => 'show')
    else
      message :object => @page
      render :action => 'show'
    end
  end
  
  protected

  def update_participation
    if logged_in? and @page and params[:action] == 'show'
      current_user.viewed(@page)
    end
  end

  # initializes default view variables. can be overwritten by subclasses.
  def setup_view
    # default, only show comment posts for the 'show' action
    @show_posts = (params[:action] == 'show')
    # by default, don't show the reply box if there are no posts
    @show_reply = @posts.any?
    @sidebar = true
    true
  end
  
  def login_or_public_page_required
    return true if @page.public? and action_name == 'show'
    return login_required
  end
  
  # this needs to be fleshed out for each action
  def authorized?
    return current_user.may?(:admin, @page)
  end
  
  def fetch_page
    if logged_in?
      # include all participations and users in the page object
      @page = Page.find :first,
         :conditions => ['pages.id = ?', params[:id]],
         :include => [{:user_participations => :user}, :group_participations]       
      # grab the current user's participation from memory
      @upart = @page.participation_for_user(current_user) if logged_in?
    else
      @page = Page.find(params[:id])
      @upart = nil
    end
    @page.discussion = Discussion.new unless @page.discussion
    
    disc = @page.discussion
    current_page = params[:posts] || disc.last_page
    @post_paging = Paginator.new self, disc.posts.count, disc.per_page, current_page
    @posts = disc.posts.find(:all, :limit => disc.per_page, :offset =>  @post_paging.current.offset)
    @post = Post.new
  end
      
  # this is aweful, and should be refactored soon.
  def breadcrumbs
    return unless params[:id]
    @page ||= Page.find_by_id(params[:id]) # page should already be loaded
    if params[:from]
      if logged_in? and params[:from] == 'people' and params[:from_id] == current_user.to_param
        add_crumb 'me', me_url
      else
        add_crumb params[:from], url_for(:controller => '/'+params[:from])
        if params[:from_id]
          if params[:from] == 'groups'
            group = Group.find_by_id(params[:from_id])
            text = group.name if group
          elsif params[:from] == 'people'
            text = params[:from_id]
          end
          if text
            add_crumb text, url_for(:controller => '/'+params[:from], :id => params[:from_id], :action => 'show')
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

    add_crumb @page.title, page_url(@page, :action => 'show')
  end
  
end
