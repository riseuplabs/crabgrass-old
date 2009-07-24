module Admin::PagesHelper

  def pages_path(arg, options={})
    admin_pages_path(arg,options)
  end

  def edit_pages_path(arg)
    edit_admin_pages_path(arg)
  end

  def new_pages_path
    new_admin_pages_path
  end

  def pages_path
    admin_pages_path
  end

  def pages_url(arg, options={})
    admin_pages_url(arg, options)
  end

end


