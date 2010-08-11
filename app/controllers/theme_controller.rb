class ThemeController < ApplicationController

  ## always cache, even in dev mode.
  def self.perform_caching; true; end
  def perform_caching; true; end

  caches_page :show

  def show
    @theme = Theme[params[:name]]
    file = File.join(params[:file])
    render :text => @theme.render_css(file), :content_type => 'text/css'
  end

end






    #last_modified = @theme.updated_at(file).utc
    #cache_time = Time.rfc2822(request.headers['If-Modified-Since']) rescue nil

#    if cache_time and last_modified <= cache_time
#raise 'cached!'
#      head(:not_modified)
#    else
#      response.headers['Cache-Control'] = 'public'
 #     response.headers['Last-Modified'] = last_modified
 #     response.headers['xxxx'] = cache_time

