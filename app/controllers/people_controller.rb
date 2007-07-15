#
# PeopleContoller
# ================================
# 
# A controller which handles collections of users, or
# for creating new users.
#
# For processing a single user, see PersonController.
#


class PeopleController < ApplicationController
  
  def index
    list
    render :action => 'list'
  end

  def list
    # @user_pages, @users = paginate :users, :per_page => 10
    if logged_in?
      @contacts = current_user.contacts
      @peers = current_user.peers
    end
  end

  def create
    if request.get?
      @user = User.new
    elsif request.post?
      @user = User.new(params[:user])
      if @user.save
        flash[:notice] = 'User was successfully created.'
        redirect_to :action => 'list'
      else
        render :action => 'new'
      end
    end
  end
    
  protected
  
  def context
    person_context
    set_banner "people/banner", Style.new(:background_color => "#6E901B", :color => "#E2F0C0")
  end
    
end
