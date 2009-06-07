# These permissions are a replacement for the following authorized? method:
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
module AssetsPermission

  def may_read_assets?(asset=@asset)
    asset and current_user.may?(:view, @asset)
  end

  alias_method :may_show_assets?, :may_read_assets?
  alias_method :may_version_assets?, :may_read_assets?

  def may_create_assets?(asset=@asset)
    asset and current_user.may?(:edit, asset.page)
  end

  alias_method :may_destroy_assets?, :may_create_assets?
end
