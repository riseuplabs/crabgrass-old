class Pages::FlagsController < ApplicationController

  before_filter :login_required

  def update
    to_update = params[:page_checked].select{|k,v| v == 'checked'}
    page_ids = to_update.map{|array| array.first.to_i}
    flags = %w/read unread watched unwatched/
    flag = (params.keys & flags).first.to_sym
    Page.flag_all(page_ids, :as => flag, :by => current_user)
  end

  protected

  def authorized?
    true
  end
end
