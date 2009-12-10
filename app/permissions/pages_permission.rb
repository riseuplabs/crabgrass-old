module PagesPermission
  def may_create_pages?
    logged_in?
  end

  alias_method :may_create_wiki_pages?, :may_create_pages?

  def may_search_pages?
    true
  end
end

