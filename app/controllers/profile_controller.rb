class ProfileController < ApplicationController

  #before_filter :login_required, :except => ['show', 'add_location', ... etc]
  prepend_before_filter :fetch_profile
  layout :choose_layout
  stylesheet 'profile'
  
  def show
    
  end

  def edit
    if request.post?
      y params
      @profile.save_from_params params['profile']
    end
  end

  # ajax
  def add_location
    render :update do |page|
      page.insert_html :bottom, 'profile_locations', :partial => 'location', :locals => {:location => Profile::Location.new}
    end
  end

  # ajax
  def add_email_address
    render :update do |page|
      page.insert_html :bottom, 'profile_email_addresses', :partial => 'email_address', :locals => {:email_address => Profile::EmailAddress.new}
    end
  end

  # ajax
  def add_im_address
    render :update do |page|
      page.insert_html :bottom, 'profile_im_addresses', :partial => 'im_address', :locals => {:im_address => Profile::ImAddress.new}
    end
  end

  # ajax
  def add_phone_number
    render :update do |page|
      page.insert_html :bottom, 'profile_phone_numbers', :partial => 'phone_number', :locals => {:phone_number => Profile::PhoneNumber.new}
    end
  end

  # ajax
  def add_note
    render :update do |page|
      page.insert_html :bottom, 'profile_notes', :partial => 'note', :locals => {:note => Profile::Note.new}
    end
  end

  # ajax
  def add_website
    render :update do |page|
      page.insert_html :bottom, 'profile_websites', :partial => 'website', :locals => {:website => Profile::Website.new}
    end
  end

  protected
 
  def fetch_profile
    return true unless params[:id]
    @profile = Profile::Profile.find params[:id]
    @entity = @profile.entity
    if @entity.is_a?(User) and current_user == @entity
      @user = @entity
    elsif @entity.is_a?(Group)
      @group = @entity
    else
      raise Exception.new('could not determine entity type')
    end
  end
  
  # always have access to self
  def authorized?
    if @user
      return true
    elsif @group
      return true if action_name == 'show'
      return true if logged_in? and current_user.member_of?(@group)
      return false
    elsif action_name =~ /add_/
     return true # TODO: this is the right way to do this
    end
  end
  
  def choose_layout
    if @user
      return 'me'
    elsif @group
      return 'group'
    else
      return 'application'
    end
  end
  
  def context
    me_context('large')
    add_context 'inbox'.t, url_for(:controller => 'inbox', :action => 'index')
  end
  
  
end
