#
# Abstract super class of all the Me controllers.
#
class Me::BaseController < ApplicationController

  before_filter :login_required, :fetch_user
  stylesheet 'me'
  # stylesheet 'messages'
  permissions 'me'

  protected

  def authorized?
    true
  end

  def fetch_user
    @user = current_user
  end

  def context
    @context = Context::Me.new(current_user)
  end

end
