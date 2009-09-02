module RootPermission

  def may_contribute_to_site?
    # this is used for displaying the 'contribute to site' link on site home
    may_admin_site?
  end

end
