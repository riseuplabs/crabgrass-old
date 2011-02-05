class EnhancedStatsViewListener < Crabgrass::Hook::ViewListener
  include Singleton

  def admin_nav(context)
    render(:partial => '/admin/base/stats_nav') if may_admin_site?
  end

  def html_head(context)
    return unless params[:controller] =~ /stats/
    stylesheet_link_tag('calendarview', :plugin => 'enhanced_stats') +
    stylesheet_link_tag('stats', :plugin => 'enhanced_stats') + 
    javascript_include_tag('calendarview', :plugin => 'enhanced_stats')
  end

end
