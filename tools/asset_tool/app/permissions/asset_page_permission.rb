module AssetPagePermission
  def authorized?
    if @page.nil?
      true
    elsif action?(:update, :add_to_gallery)
      current_user.may?(:edit,@page)
    elsif action?(:generate_preview, :show)
      @page.public? or current_user.may?(:view,@page)
    else
      current_user.may?(:admin, @page)
    end
  end
end
