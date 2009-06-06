module GalleryPagePermission
  def authorized?
    if @page.nil?
      true
    elsif action?(:add, :remove, :find, :upload, :add_star, :remove_star,
                  :change_image_title, :make_cover)
      current_user.may?(:edit, @page)
    elsif action?(:show, :comment_image, :detail_view, :slideshow, :download)
      @page.public? or current_user.may?(:view,@page)
    else
      current_user.may?(:admin, @page)
    end
  end
end
