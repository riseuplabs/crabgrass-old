module Admin::CustomAppearancesHelper
  def admin_custom_appearances_path
    if ca = current_site.custom_appearance
      edit_admin_custom_appearance_url(ca)
    else
      new_admin_custom_appearance_url
    end
  end

  def custom_appearance_path(*args)
    admin_custom_appearance_path(*args)
  end
end
