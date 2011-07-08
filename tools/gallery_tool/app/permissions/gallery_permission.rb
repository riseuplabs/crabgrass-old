module GalleryPermission

  # this authorized function is used both for the gallery as a whole
  # as for images in the gallery.
  def authorized?
    case params[:action].to_sym
    when :show
      @page.public or current_user.may?(:view, @page)
    when :edit, :update
      current_user.may?(:edit, @page)
    when :new, :create
      if @page.nil? or @page.new_record?
        may_create_page?
      else
        current_user.may?(:edit, @page)
      end
    when :destroy
      current_user.may?(:admin, @page)
    when :comment, :add_star, :remove_star
      current_user.may(:view, @page)
    end
  end

end
