module AdminStatsHelper

  def add_calendar_js(trigger, el)
    "var calendar = Calendar.setup( { triggerElement: '#{trigger}', dateField: '#{el}' });"
  end

  def stats_subheader(content)
    th = content_tag(:th, content, {:class => 'subhead bordered', :colspan => 2}) 
    content_tag(:tr, th)
  end

  def stats_tr(title, total)
    td = content_tag(:td, title) + content_tag(:td, total)
    content_tag(:tr, td)
  end

end
