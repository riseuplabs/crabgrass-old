module CollectionPermission

  # Collection
  #  def authorized?
  #    if @page
  #      if %w(show print diff version versions).include? params[:action]
  #        @page.public? or current_user.may?(:view, @page)
  #      elsif %w(edit break_lock).include? params[:action]
  #        current_user.may?(:edit, @page)
  #      else
  #        current_user.may?(:admin, @page)
  #      end
  #    else
  #      true
  #    end
  #  end
  def may_show_collection?
    @page.nil? or
    @page.public? || current_user.may?(:view, @page)
  end

  %w(print diff version versions).each{ |action|
    alias_method "may_#{action}_collection?".to_sym, :may_show_collection?
  }

  def may_edit_collection?
    @page.nil? or
    current_user.may?(:edit, @page)
  end

  alias_method :may_break_lock_collection?, :may_edit_collection?

  # Gallery
  #  def authorized?
  #    if @page.nil?
  #      true
  #    elsif action?(:add, :remove)
  #      current_user.may?(:edit,@page)
  #    elsif action?(:show)
  #      @page.public? or current_user.may?(:view,@page)
  #    else
  #      current_user.may?(:admin, @page)
  #    end
  #  end
  alias_method :may_show_gallery?, :may_show_collection?

  %w(add remove).each{ |action|
    alias_method "may_#{action}_gallery?".to_sym, :may_edit_collection?
  }
end
