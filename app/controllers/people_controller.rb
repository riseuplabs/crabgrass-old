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
    return unless logged_in?

    @users = current_user.contacts.alphabetized(@letter_page).paginate :page => @page_number, :per_page => @per_page
    # what letters can be used for pagination
    @pagination_letters = current_user.contacts.logins_only.collect{|u| u.login.first.upcase}.uniq
  end

  def peers
    return unless logged_in?

    @users = User.peers_of(current_user).alphabetized(@letter_page).paginate :page => @page_number, :per_page => @per_page
     # what letters can be used for pagination
    @pagination_letters = User.peers_of(current_user).logins_only.collect{|u| u.login.first.upcase}.uniq
  end

  def directory
    return unless logged_in?

    @users = User.alphabetized(@letter_page).paginate :page => @page_number, :per_page => @per_page
    # what letters can be used for pagination
    @pagination_letters = User.logins_only.collect{|u| u.login.first.upcase}.uniq
  end

  protected

  before_filter :prepare_pagination
  def prepare_pagination
    @page_number = params[:page] || 1
    @per_page = 10
    @letter_page = params[:letter] || ''
  end
  
  def context
    person_context
    #set_banner "people/banner", Style.new(:background_color => "#6E901B", :color => "#E2F0C0")
    set_banner "people/banner", Style.new(:color => "#eef", :background_color => "#1B5790")
  end

end
