class StylesheetsController < ApplicationController
  after_filter :set_content_type
  session :off

  def site_specific
    path = params[:path].clone
    site_domain = path.shift
    site = Site.find_by_domain(site_domain)
    
    if site.nil?
      raise ActionController::RoutingError, "This looks like site-specific css, but the site does not exist - \"#{request.path}\""
    end
    
    # fresh_when(:last_modified => Time.now)
    render :text => "" #site.stylesheet_render_options(path)
  end

  private
  def set_content_type
    headers["Content-Type"] = "text/css"
  end
end
