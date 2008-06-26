class MeController < ApplicationController

  def dashboard
    if request.post?
      path = build_filter_path(params[:search])
      redirect_to me_url(:action => 'dashboard') + path   
    else
      params[:path]||=[]
      @pages = Page.find_by_path(params[:path]+['limit','40'], options_for_me)
    end
  end
  
end

