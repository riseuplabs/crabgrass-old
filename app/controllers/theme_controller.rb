#
# Our CSS is dynamically generated and then statically cached. There are a
# couple ways we could do this: one would be to generate the CSS files when
# the urls are referenced in the html header (ie <stylesheet ... />)
#
# Another method would be to make the stylesheet urls hit a controller, and
# have that controller re-render the stylesheets. This is what we have done
# here. I am not sure which method is better, but this seems to work.
#
# This does not work, however, for destroying the cache. For this, we do
# use the first method: Theme.stylesheet_url(..) will destroy the cached 
# sheets in development mode if they need to be re-rendered. It might
# make more sense to combine both the rendering and the destroying in the
# same place. One advantage of the method here is that we can display
# a nice stylesheet specific error message if there is a sass syntax error.
#


class ThemeController < ApplicationController

  ## always enable cache, even in dev mode.
  def self.perform_caching; true; end
  def perform_caching; true; end

  attr_accessor :cache_css
  caches_page :show, :if => Proc.new {|ctrl| ctrl.cache_css}

  def show
    render :text => @theme.render_css(@file), :content_type => 'text/css'
  rescue Sass::SyntaxError => exc
    self.cache_css = false
    render :text => @theme.error_response(exc)
    expire_page :name => params[:name], :file => params[:file]
  end

  # don't cache css if '_refresh' is in the theme or stylesheet name.
  # useful for debugging.
  prepend_before_filter :get_theme
  def get_theme
    self.cache_css = true
    [params[:name], *params[:file]].each do |param|
      if param =~ /_refresh/
        param.sub!('_refresh','')
        self.cache_css = false
      end
    end
    @theme = Crabgrass::Theme[params[:name]]
    @file = File.join(params[:file])
    @theme.clear_cache(@file) unless self.cache_css
  end

end

