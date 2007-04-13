# super class controller for all page types

class Tool::BaseController < ApplicationController
  layout 'tool'
  #in_place_edit_for :page, :title
  
  prepend_before_filter :fetch_page_data
  append_before_filter :login_or_public_page_required
  skip_before_filter :login_required
  append_before_filter :setup_view
  append_after_filter :update_participation
  
  def initialize(options={})
    super()
    @user = options[:user]   # the user context, if any
    @group = options[:group] # the group context, if any
    @page = options[:page]   # the page object, if already fetched
  end
  
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
    name = params[:page][:name].to_s.nameize
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
    @page.name = name if name.any?
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
  
  def fetch_page_data
    if logged_in?
      # grab the current user's participation from memory
      @upart = @page.participation_for_user(current_user) if logged_in?
    else
      @upart = nil
    end
    @page.discussion = Discussion.new unless @page.discussion
    
    disc = @page.discussion
    current_page = params[:posts] || disc.last_page
    @post_paging = Paginator.new self, disc.posts.count, disc.per_page, current_page
    @posts = disc.posts.find(:all, :limit => disc.per_page, :offset =>  @post_paging.current.offset)
    @post = Post.new
  end
      
  def breadcrumbs
    return unless @page
    if @group
      add_crumb 'groups', groups_url
      add_crumb @group.name, groups_url(:action => 'show', :id => @group)
      set_banner 'groups/banner_small', @group.style
    elsif @user and current_user != @user
      add_crumb 'people', people_url
      add_crumb @user.login, people_url(:action => 'show', :id => @user)
      set_banner 'people/banner_small', @user.style
    elsif @user and current_user == @user
      add_crumb 'me', me_url
    elsif @page.group_name
      add_crumb 'groups', groups_url
      add_crumb @page.group_name, groups_url(:action => 'show', :id => @page.group_name)      
      set_banner 'groups/banner_small', @group.style
    end
    add_crumb @page.title, page_url(@page, :action => 'show')
  end
  
end
