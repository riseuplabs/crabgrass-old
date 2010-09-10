module RateManyPagePermission
  def may_vote_page?(page=@page)
    may_edit_page?(page)
  end

  alias_method :may_vote_one_page?, :may_vote_page?
end
