=begin
PeopleContoller
================================

A controller which handles collections of users, or
for creating new users.

For processing a single user, see PersonController.

=end

class PeopleController < ApplicationController
  
  def index
    @users = User.recent.paginate :page => @page_number, :per_page => @per_page if logged_in?
  end

  def contacts
    @users = current_user.contacts.alphabetized.paginate :page => @page_number, :per_page => @per_page if logged_in?
  end

  def peers
    # peers are alphabetized by default
    @users = current_user.peers.paginate :page => @page_number, :per_page => @per_page if logged_in?
  end

  def directory
    @users = User.alphabetized.paginate :page => @page_number, :per_page => @per_page if logged_in?
  end

  protected

  before_filter :prepare_pagination
  def prepare_pagination
    @page_number = params[:page] || 1
    @per_page = 10
  end
  
  def context
    person_context
    #set_banner "people/banner", Style.new(:background_color => "#6E901B", :color => "#E2F0C0")
    set_banner "people/banner", Style.new(:color => "#eef", :background_color => "#1B5790")
  end
    
end
