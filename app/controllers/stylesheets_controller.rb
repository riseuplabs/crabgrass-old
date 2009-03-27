class StylesheetsController < ApplicationController
  after_filter :set_content_type
  session :off

  def style
    path = File.join(params[:path])

    appearance = current_site && current_site.custom_appearance
    render :text => CustomAppearance.generate_css(path, appearance)
  end

  private
  def set_content_type
    headers["Content-Type"] = "text/css"
  end
end
