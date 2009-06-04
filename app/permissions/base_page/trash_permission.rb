module BasePage::TrashPermission 
  #  most of these permissions are taken care of in 
  #  base_page (delete, undelete, destroy)
  [:close, :show_popup].each do |action|
    alias_method "may_#{action}_trash?".to_sym, :may_delete_base_page?
  end
end
