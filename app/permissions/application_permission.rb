module ApplicationPermission

  protected

  def may_admin_site?
    # make sure we actually have a site
    logged_in? and
    !current_site.new_record? and
    current_user.may?(:admin, current_site)
  end

  def may_create_pages?
    logged_in?
  end

  alias_method :may_create_wiki_pages?, :may_create_pages?
end
