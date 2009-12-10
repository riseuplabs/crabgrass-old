class Admin::BaseController < ApplicationController

  include ActionView::Helpers::TagHelper
  include FlashMessageHelper
  include AuthenticatedSystem

  #layout 'admin'

  #stylesheet('admin')

  helper 'admin/base', 'admin/pages', 'admin/posts', 'admin/email_blasts', 'admin/announcements', 'admin/custom_appearances', PageHelper, UrlHelper, FlashMessageHelper, LinkHelper, ApplicationHelper, TimeHelper


  before_filter :login_required
  before_filter :set_active_tab
  before_render :context_if_appropriate

  include Admin::GroupsHelper
  include Admin::UsersHelper
  include Admin::MembershipsHelper
  include Admin::PagesHelper
  include Admin::PostsHelper
  include Admin::EmailBlastsHelper
  include Admin::AnnouncementsHelper

  include ControllerExtension::CurrentSite

  protect_from_forgery :secret => Conf.secret

  permissions 'admin/base'

  def index
  end

  private

  def set_active_tab
    controller = params[:controller].sub(/admin\//, '')
    action = params[:action]
    @admin_active_tab = "#{controller}_#{action}"
    @active_tab = :admin
  end

  protected

  def context
    @left_column = render_to_string :partial => 'admin/base/navigation'
  end

  def context_if_appropriate
    if !@skip_context and normal_request?
      @skip_context = true
      context()
    end
    true
  end

  def normal_request?
    format = request.format.to_sym
    response.redirected_to.nil? and
    (format == :html or format == :all or format == :gif)
  end

end
