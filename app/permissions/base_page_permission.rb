module BasePagePermission

  def may_update_page?(page = @page)
    current_user.may?(:admin, page)
  end

  [:undelete].each do |action|
    alias_method "may_#{action}_page?".to_sym, :may_update_page?
  end

  def may_destroy_page?(page = @page)
    current_user.may?(:destroy, page)
  end

  # we are using may_remove_page from trash controllers.
  [:remove].each do |action|
    alias_method "may_#{action}_page?".to_sym, :may_destroy_page?
  end
end
