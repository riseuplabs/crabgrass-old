module GeoLocationPermission

  def may_edit_geo_location?(location=@location)
    return false unless !location.profile.nil?
    may_edit_profile?(location.profile.entity)
  end
  alias_method :may_update_geo_location?, :may_edit_geo_location?

  def may_create_geo_location?(profile=@profile)
    may_edit_profile?(profile.entity)
  end
  alias_method :may_new_geo_location?, :may_create_geo_location?

end
