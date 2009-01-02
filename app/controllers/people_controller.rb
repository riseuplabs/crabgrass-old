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
    page = params[:page] || 1
    per_page = 10
    
    @users = User.paginate :page => page, :per_page => per_page if @type.nil? || @type == "users"
    if logged_in?
      @contacts = current_user.contacts.paginate :page => page, :per_page => per_page if @type.nil? || @type == "contacts"
      @peers = current_user.peers.paginate :page => page, :per_page => per_page if @type.nil? || @type == "peers"
    end
  end
     
  def users
    @type = "users"
    index
  end
  
  def contacts
    @type = "contacts"
    index
  end
    
  def peers
    @type = "peers"
    index
  end
    
  protected
  
  def context
    person_context
    #set_banner "people/banner", Style.new(:background_color => "#6E901B", :color => "#E2F0C0")
    set_banner "people/banner", Style.new(:color => "#eef", :background_color => "#1B5790")
  end
    
end
