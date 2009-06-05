module CustomAppearancesPermission 
  #  def authorized?
  #    return false unless logged_in?
  #    if current_site and @appearance == current_site.custom_appearance and current_site.super_admin_group
  #      if current_user.may?(:admin, current_site.super_admin_group)
  #        return true
  #      end
  #    end
  #
  #    if current_site and @appearance == current_site.custom_appearance
  #      return true if current_user.may?(:admin, current_site)
  #    end
  #
  #    return false
  #  end
  #
  def may_update_custom_appearances?(appearance=@appearance)
    return false unless logged_in? and
    current_site and
    appearance == current_site.custom_appearance 

    current_user.may?(:admin, current_site) or
    current_site.super_admin_group && current_user.may?(:admin, current_site.super_admin_group)
  end
    
  %w(edit available).each{ |action|
    alias_method "may_#{action}_custom_appearances?".to_sym, :may_update_custom_appearances?
  }
end
