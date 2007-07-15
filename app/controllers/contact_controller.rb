#
# a controller for managing contacts
#

class ContactController < ApplicationController

  verify :method => :post, :only => [:remove]
  layout 'people'
  
  
  
  def add
    if request.post?
      return redirect_to(url_for_user(@user)) if params[:cancel]
      page = Page.make :request_for_contact, :user => current_user, :contact => @user, :message => params[:message]
      if page.save
        message :success => 'Your contact request has been sent to %s.' / @user.login
        disc = Page.make :contact_discussion, :user => current_user, :contact => @user, :message => params[:message]
        disc.save
        disc.add_link page
        redirect_to url_for_user(@user)
      else
        message :object => page
      end
    end 
  end
  
  def remove
    current_user.contacts.delete(@user)
    message :success => '%s has been removed from your contact list.' / @user.login
    redirect_to url_for_person(@user)
  end

  protected
  
  prepend_before_filter :fetch_user
  def fetch_user
    @user ||= User.find_by_login params[:id] if params[:id]
    @is_contact = (logged_in? and current_user.contacts.include?(@user))
    true
  end
  
  def context
    person_context
    add_context 'contact', url_for(:controller => 'contact', :action => 'add', :id => @user)
  end
  
end

