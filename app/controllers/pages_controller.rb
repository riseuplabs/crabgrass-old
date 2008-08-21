=begin

PagesController
---------------------------------

If you have an actual page, then the controller that controls it is BasePageController
or one of the many subclasses of this controller (one for each page type). 

This controller, on the other hand, is for cases when we don't have an actual
page or you don't know the page type in question.

For example, there are two create() actions, one in PagesControllers
and one in BasePageController. The one in PagesController handles the first
step where you choose a page type. The one in BasePageController handles the
next step where you enter in data. This step is handled by BasePageController
so that each tool can define their own method of creation.

=end

class PagesController < ApplicationController

  helper BasePageHelper
  
  before_filter :login_required
  prepend_before_filter :fetch_page

  # if this controller is called by DispatchController,
  # then we may be passed some objects that are already loaded.
  def initialize(options={})
    super()
    @pages = options[:pages] # a list of pages, if already fetched
  end  

  ##############################################################
  ## PUBLIC ACTIONS

  # a simple form to allow the user to select which type of page
  # they want to create. the actual create form is handled by
  # BasePageController (or overridden by the particular tool). 
  def create
    @stylesheet = 'page_creation'
  end
         
  # for quickly creating a wiki
  def create_wiki
    group = Group.get_by_name(params[:group])
    if !logged_in?
      # should never reach this code, because of before_filter :login_required
      flash_message :error => "You must first login."
    elsif group.nil? or !current_user.member_of?(group)
      flash_message :error => "Group does not exist or you do not have permission to create a page for that group"
    else
      page = Page.make :wiki, {:user => current_user, :group => group, :name => params[:name]}
      page.save
      redirect_to page_url(page)
      return
    end
    render :text => ''
  end

  def access
    if request.post?
      if params[:remove_group]
        @page.remove(Group.find_by_id(params[:remove_group]))
      elsif params[:remove_user]
        @page.remove(User.find_by_id(params[:remove_user]))
      # maybe we shouldn't allow removal of last entity (?) -- now handled in view -af
      elsif params[:add_name]
        access = params[:access] || :admin
        if group = Group.get_by_name(params[:add_name])
          if current_user.may_pester? group
            @page.add group, :access => access
          else
            flash_message :error => 'you do not have permission to do that'
          end
        elsif user = User.find_by_login(params[:add_name])
          if current_user.may_pester? user
            @page.remove user
            @page.add user, :access => access
          else
            flash_message :error => 'you do not have permission to do that'
          end
        else
          flash_message :error => 'group or user not found'
        end
      end
      @page.save
    end
  end

  def participation
    
  end
  
  def history
  
  end
        
  protected
  
  def authorized?
    # see BaseController::authorized?
    if @page
      return current_user.may?(:admin, @page)
    else
      return true
    end
  end

  def context
#    return true unless request.get?  #I don't know what the purpose of this is, but commenting it out makes access look better after removing access  --af
    @group ||= Group.find_by_id(params[:group_id]) if params[:group_id]
    @user ||= User.find_by_id(params[:user_id]) if params[:user_id]
    @user ||= current_user 
    page_context
    true
  end
  
  def fetch_page
    @page = Page.find_by_id(params[:id]) if params[:id]
    @upart = (@page.participation_for_user(current_user) if logged_in? and @page)
    true
  end
  
end
