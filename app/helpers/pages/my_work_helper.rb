module Pages::MyWorkHelper
  def my_work_views
    {I18n.t(:watched_pages) => :watched,
      I18n.t(:editor_pages) => :editor,
      I18n.t(:owner_pages) => :owner,
      I18n.t(:unread_pages) => :unread}
  end
end
