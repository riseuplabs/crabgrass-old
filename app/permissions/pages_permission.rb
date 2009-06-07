# These permissions are a replacement for the following authorized? method:
#  def authorized?
#    # see BaseController::authorized?
#    if @page
#      return current_user.may?(:admin, @page)
#    else
#      return true
#    end
#  end
module PagesPermission
  def may_create_pages?(page=@page)
    !page or current_user.may?(:admin, @page)
  end

  alias_method :may_create_wiki_pages?, :may_create_pages?
end
