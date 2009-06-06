module AssetsPermission
#  def authorized?
#    if @asset
#      if action_name == 'show' || action_name == 'version'
#        current_user.may?(:view, @asset)
#      elsif action_name == 'create' || action_name == 'destroy'
#        current_user.may?(:edit, @asset.page)
#      end
#    else
#      false
#    end
#  end

  def may_read_assets?(asset=@asset)
    asset and current_user.may?(:view, @asset)
  end

  %w(show version).each{ |action|
    alias_method "may_#{action}_assets?".to_sym, :may_read_assets?
  }

  def may_create_assets?(asset=@asset)
    asset and current_user.may?(:edit, asset.page)
  end

  alias_method :may_destroy_assets?, :may_create_assets?
end
