module BasePage::AssetsPermission 
#  def authorized?
#    current_user.may? :edit, @page
#  end
  def may_create_assets?(page=@page)
    page and current_user.may? :edit, page
  end

  %w(destroy close show_popup).each{ |action|
    alias_method "may_#{action}_assets?".to_sym, :may_create_assets?
  }
end
