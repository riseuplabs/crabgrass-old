# handles pagination options for all controllers
# they should override these methods for special behavior

module ControllerExtension::PaginationOptions

  protected

  def pagination_default_per_page
    Conf.pagination_size
  end

  def pagination_default_page
    # nil is fine here, it leaves up to will_paginate to decide what it wants to do
    nil
  end

  # if +:page+ is not set, it will try params[:page] and then default page (usually nil)
  # if +:per_page+ is not set, it will use pagination_default_per_page method
  def pagination_params(opts = {})
    page = opts[:page] || params[:page] || pagination_default_page
    per_page = opts[:per_page] || pagination_default_per_page

    {:page => page, :per_page => per_page }
  end
end
