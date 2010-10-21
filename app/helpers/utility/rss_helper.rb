##
## RSS SUPPORT
##

module Utility::RssHelper

  protected

  def group_search_rss
    '<link rel="alternate" href="%s" title="%s" type="application/rss+xml" />' % [
       url_for(group_search_url(:action => params[:action], :path => current_rss_path)),
       I18n.t(:rss_feed)
    ]
  end

  def me_rss
    '<link rel="alternate" href="/me/inbox/list/rss" title="%s %s" type="application/rss+xml" />' % [current_user.name, I18n.t(:me_inbox_link)]
  end

  # TODO: rewrite this using the rails 2.0 way, with respond_to do |format| ...
  # although, this will be hard, since it seems *path globbing doesn't work
  # with :format.
  def handle_rss(locals)
    if rss_request?
      response.headers['Content-Type'] = 'application/rss+xml'
      render :partial => '/pages/rss', :locals => locals
      return true
    else
      return false
    end
  end

  # return true if this is an rss request. Unfornately, for routes with
  # glob *paths, we can't use :format. the ParsedPath @path, however, does
  # a good job of identifying trailing format codes that are not otherwise
  # unparsable as part of the path.
  def rss_request?
    @path.format == 'rss'
  end

  # used to build an rss link from the current params[:path]
  def current_rss_path
    @path.format('rss') # returns a copy of @path with format set
  end

end

