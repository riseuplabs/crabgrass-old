=begin
PeopleContoller
================================

A controller which handles collections of users, or
for creating new users.

For processing a single user, see PersonController.

=end

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
    
  protected
  
  def context
    person_context
    set_banner "people/banner", Style.new(:background_color => "#6E901B", :color => "#E2F0C0")
  end
    
end
