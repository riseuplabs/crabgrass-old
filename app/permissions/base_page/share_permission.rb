module BasePage::SharePermission 
#  def authorized?
#    if @page
#      current_user.may? :admin, @page
#    else
#      true
#    end
#  end
  def may_update_share?(page=@page)
    !page or current_user.may? :admin, page
  end

  %w(notify show_popup).each{ |action|
    alias_method "may_#{action}_share?".to_sym, :may_update_share?
  }
  
end
