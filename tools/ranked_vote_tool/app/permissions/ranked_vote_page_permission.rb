module RankedVotePagePermission
  def authorized?
    return super unless @page
    current_user.may?(:admin, @page)
  end
end
