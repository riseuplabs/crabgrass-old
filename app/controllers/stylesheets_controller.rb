class StylesheetsController < ApplicationController
  after_filter :set_content_type
  session :off

  def site_specific
    path = params[:path].clone
    sass_root_path = './public/stylesheets/sass'
    sass_load_paths = ['.', sass_root_path]

    fpath = File.join([sass_root_path] + path).gsub(".css", ".sass")
    engine = Sass::Engine.new(File.read(fpath), :load_paths => sass_load_paths)

    # site_domain = path.shift
    # site = Site.find_by_domain(site_domain)

    # if site.nil?
    #       raise ActionController::RoutingError, "This looks like site-specific css, but the site does not exist - \"#{request.path}\""
    #     end

    render :text => engine.render
  end

  private
  def set_content_type
    headers["Content-Type"] = "text/css"
  end
end
