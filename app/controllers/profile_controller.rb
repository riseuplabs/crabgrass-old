class ProfileController < ApplicationController
  permissions 'profile'

  before_filter :fetch_profile, :login_required
  stylesheet 'profile'
  helper 'me/base'
  #permissions 'profiles'
  verify :method => :post, :only => :update

  def show
  end

  def edit
    if @user
      @tabs = 'me/base/profile_tabs'
    end
    if request.post?
      @profile.save_from_params params['profile']
      if @profile.valid?
        flash_message :success => I18n.t(:profile_saved)
        redirect_to :controller => 'profile', :action => 'edit', :id => @profile.type
      end
    end
  end

  # ajax
  def add_location
    multiple = params[:multiple]
    render :update do |page|
      page.insert_html :bottom, 'profile_locations', :partial => 'location', :locals => {:location => ProfileLocation.new, :multiple => multiple}
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

#  # removes everything from params that isn't to be included, due to the profile
#  # settings of the current site.
#  def apply_settings_to_params!
#    # values are preset (select field), so we ignore them
#    ignore = {
#      'location' => ['location_type'],
#      'note' => ['note_type']
#    }
#    %w(crypt_key email_address location website note im_address
#       phone_number).each do |element|
#      next unless (this_params = params['profile'][plural = element.pluralize])
#      # elements with all fields empty shouldn't be fatal errors that prevent us
#      # from saving.
#      valid_keys = this_params.map do |key, value|
#        values = ((ignored_keys = ignore[element]) ?
#                  value.allow(value.keys-ignored_keys).values :
#                  value.values)
#        values.map(&:empty?).include?(false) ? key : nil
#      end.compact
#      params['profile'][plural] = this_params.allow(valid_keys)
#    end
#  end

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

  def authorized?
    if params[:action] =~ /^add_/
      true
    else
      may_action?(params[:action], @entity)
    end
  end

end
