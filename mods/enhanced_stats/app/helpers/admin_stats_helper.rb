module AdminStatsHelper

  def add_calendar_js(trigger, el)
    "var calendar = Calendar.setup( { triggerElement: '#{trigger}', dateField: '#{el}' });"
  end

  def stats_subheader(content, comment=nil)
    comment = comment.nil? ? '' : content_tag(:span, comment, {:class => 'comment'})
    th = content_tag(:th, content+comment, {:class => 'subhead bordered', :colspan => 2}) 
    content_tag(:tr, th)
  end

  def stats_tr(title, total)
    td = content_tag(:td, title) + content_tag(:td, total)
    content_tag(:tr, td)
  end

  def show_results_for(collection, title)
    html = stats_subheader(title)
    collection.each do |res|
      html += stats_tr(res[0], res[1])
    end
    html
  end

end
