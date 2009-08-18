#
# Abstract super class of all the Me controllers.
#
class Me::BaseController < ApplicationController

  before_filter :login_required, :fetch_user
  stylesheet 'me'
  permissions 'me'

  protected

  def authorized?
    true
  end

  def fetch_user
    @user ||= current_user
  end

  def context
    me_context('large')
    @left_column = render_to_string :partial => 'me/sidebar'
  end

end
