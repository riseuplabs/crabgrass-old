module AssetsPermission

  def may_show_assets?(asset=@asset)
    return false unless asset
    asset.public? or current_user.may?(:view, @asset.page)
  end

  alias_method :may_version_assets?, :may_show_assets?

  def may_create_assets?(asset=@asset)
    asset and current_user.may?(:edit, asset.page)
  end

  alias_method :may_destroy_assets?, :may_create_assets?
end
