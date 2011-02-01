class ProfileController < ApplicationController
  permissions 'profile'

  before_filter :fetch_profile, :login_required
  stylesheet 'profile'
  helper 'me/base', 'locations', 'autocomplete'
  #permissions 'profiles'
  verify :method => :post, :only => :update
  layout 'header'

  def show
  end

  def edit
    if request.post?
      @profile.save_from_params params['profile']
      if @profile.valid?
        flash_message :success => I18n.t(:profile_saved)
        redirect_to :controller => 'profile', :action => 'edit', :id => @profile.type
      end
    end
  end
 
  def edit_location
    return unless request.xhr?
    @profile.update_location(params)
    render :nothing => true
  end

  # ajax
  def add_location
    #multiple = params[:multiple]
    render :update do |page|
      page.insert_html :bottom, 'profile_locations', :partial => '/locations/select_form'
      page.hide 'add_location_link'
    end
  end

  # ajax
  def add_email_address
    multiple = params[:multiple]
    render :update do |page|
      page.insert_html :bottom, 'profile_email_addresses', :partial => 'email_address', :locals => {:email_address => ProfileEmailAddress.new, :multiple => multiple}
    end
  end

  # ajax
  def add_im_address
    multiple = params[:multiple]
    render :update do |page|
      page.insert_html :bottom, 'profile_im_addresses', :partial => 'im_address', :locals => {:im_address => ProfileImAddress.new, :multiple => multiple}
    end
  end

  # ajax
  def add_phone_number
    multiple = params[:multiple]
    render :update do |page|
      page.insert_html :bottom, 'profile_phone_numbers', :partial => 'phone_number', :locals => {:phone_number => ProfilePhoneNumber.new, :multiple => multiple}
    end
  end

  # ajax
  def add_note
    multiple = params[:multiple]
    render :update do |page|
      page.insert_html :bottom, 'profile_notes', :partial => 'note', :locals => {:note => ProfileNote.new, :multiple => multiple}
    end
  end

  # ajax
  def add_website
    multiple = params[:multiple]
    render :update do |page|
      page.insert_html :bottom, 'profile_websites', :partial => 'website', :locals => {:website => ProfileWebsite.new, :multiple => multiple}
    end
  end

  def add_crypt_key
    multiple = params[:multiple]
    render :update do |page|
      page.insert_html :bottom, 'profile_crypt_keys', :partial => 'crypt_key', :locals => {:crypt_key => ProfileCryptKey.new, :multiple => multiple}
    end
  end

  protected

  def fetch_profile
    return true unless params[:id]
    if params[:id] == 'public' #&& @site.profiles.public?
      @profile = current_user.profiles.public
    elsif params[:id] == 'private' #&& @site.profiles.private?
      @profile = current_user.profiles.private
    #else
    #  @profile = Profile.find params[:id]
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

  #def fetch_profile_settings
  #  return true unless @profile
  #  @profile_settings = (@profile.public? ? @site.profiles.public :
  #                       @site.profiles.private)
  #end

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
    account_context('large')
    @banner = render_to_string :partial => 'me/banner'
  end

  def authorized?
    if params[:action] =~ /^add_/
      true
    else
      may_action?(params[:action], @entity)
    end
  end

end
