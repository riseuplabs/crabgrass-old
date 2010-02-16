module PagesPermission
  def may_create_pages?
    logged_in?
  end

  def may_new_pages?
    logged_in?
  end

  def may_index_pages?
    logged_in?
  end

  def may_all_pages?
    logged_in?
  end

  def may_my_work_pages?
    logged_in?
  end

  def may_notification_pages?
    logged_in?
  end

  def may_mark_pages?
    logged_in?
  end

  alias_method :may_create_wiki_pages?, :may_create_pages?

  def may_search_pages?
    true
  end
end

