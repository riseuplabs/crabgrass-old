module BasePagePermission
  # teachers should be able to see all of their students pages.

  def may_show_page?(page = @page)
    !page or current_user.may?(:view, page) or
    may_view_as_teacher?(page)
  end

  protected

  def may_view_as_teacher?(page)
    user_ids = page.user_participations.collect{|p|p.user_id}
    (user_ids & current_user.student_id_cache).empty
  end
end
