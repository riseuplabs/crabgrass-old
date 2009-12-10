#
# Abstract super class of all the people controllers.
#
class People::BaseController < ApplicationController

  #stylesheet 'people'
  #permissions 'people'

  protected

  def context
    person_context
  end

  prepend_before_filter :fetch_user
  def fetch_user
    @user ||= User.find_by_login params[:person_id] if params[:person_id]
    true
  end

end
