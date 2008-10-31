require 'svg/svg' 

class VisualizeController < ApplicationController
  before_filter :login_required
  prepend_before_filter :find_group

  def show
    # return xhtml so that svg content is rendered correctly --- only works for firefox (?)    
    response.headers['Content-Type'] = 'application/xhtml+xml'       
  end

  protected 

  def find_group
    @group = Group.find_by_name params[:id] if params[:id]
  end
  
  def authorized?
    current_user.member_of?(@group)
  end    
  
end

