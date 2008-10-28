class ProfileController < ApplicationController

  before_filter :login_required
  prepend_before_filter :fetch_profile
  #layout :choose_layout
  stylesheet 'profile'
  
  def show
  end

  def edit
    if request.post?
      @profile.save_from_params params['profile']
    end
  end

  # ajax
  def add_location
    render :update do |page|
      page.insert_html :bottom, 'profile_locations', :partial => 'location', :locals => {:location => ProfileLocation.new}
    end
  end

  # ajax
  def add_email_address
    render :update do |page|
      page.insert_html :bottom, 'profile_email_addresses', :partial => 'email_address', :locals => {:email_address => ProfileEmailAddress.new}
    end
  end

  # ajax
  def add_im_address
    render :update do |page|
      page.insert_html :bottom, 'profile_im_addresses', :partial => 'im_address', :locals => {:im_address => ProfileImAddress.new}
    end
  end

  # ajax
  def add_phone_number
    render :update do |page|
      page.insert_html :bottom, 'profile_phone_numbers', :partial => 'phone_number', :locals => {:phone_number => ProfilePhoneNumber.new}
    end
  end

  # ajax
  def add_note
    render :update do |page|
      page.insert_html :bottom, 'profile_notes', :partial => 'note', :locals => {:note => ProfileNote.new}
    end
  end

  # ajax
  def add_website
    render :update do |page|
      page.insert_html :bottom, 'profile_websites', :partial => 'website', :locals => {:website => ProfileWebsite.new}
    end
  end
  

  def add_crypt_key
    render :update do |page|
      page.insert_html :bottom, 'profile_crypt_keys', :partial => 'crypt_key', :locals => {:crypt_key => ProfileCryptKey.new}
    end
  end
  
  protected
 
  def fetch_profile
    return true unless params[:id]
    if params[:id] == 'public'
      @profile = current_user.profiles.public
    elsif params[:id] == 'private'
      @profile = current_user.profiles.private
    else
      @profile = Profile.find params[:id]
    end
    @entity = @profile.entity
    if @entity.is_a?(User)
      @user = @entity
    elsif @entity.is_a?(Group)
      @group = @entity
    else
      raise Exception.new("could not determine entity type for profile: #{@profile.inspect}")
    end
  end
  
  # always have access to self
  def authorized?
    if @entity.is_a?(User) and current_user == @entity
      return true
    elsif @entity.is_a?(Group)
      return true if action_name == 'show'
      return true if logged_in? and current_user.member_of?(@entity)
      return false
    elsif action_name =~ /add_/
     return true # TODO: this is the right way to do this
    end
  end
  
  before_filter :setup_layout
  def setup_layout
    if @user
      #@tabs = 'me/base/profile_tabs'
      @left_column = render_to_string :partial => 'me/sidebar'
    elsif @group
      #@tabs = 'profile/side_tabs'
    end
  end
  
  def context
    me_context('large')
    @banner = render_to_string :partial => 'me/banner'
  end

end
