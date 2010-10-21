begin
  require 'svg/svg'
  SVG_ENABLED=true
rescue LoadError => exc
  SVG_ENABLED=false
end

class VisualizeController < ApplicationController
  before_filter :login_required
  prepend_before_filter :find_group

  def show
    return unless SVG_ENABLED
    # return xhtml so that svg content is rendered correctly --- only works for firefox (?)
    response.headers['Content-Type'] = 'application/xhtml+xml'
  end

  protected

  def find_group
    @group = Group.find_by_name params[:id] if params[:id]
  end

end
