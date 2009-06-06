module RateManyPagePermission
#  def authorized?
#    if @page
#      current_user.may?(:admin, @page)
#    else
#      true
#    end
#  end

  def fetch_poll
    return true unless @page
    @poll = @page.data
  end
end
