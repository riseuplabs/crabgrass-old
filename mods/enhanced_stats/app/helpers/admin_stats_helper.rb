module AdminStatsHelper

  def add_calendar_js(trigger, el)
    "var calendar = Calendar.setup( { triggerElement: '#{trigger}', dateField: '#{el}' });"
  end

  def show_results_for(collection)
    html = ''
    collection.each do |res|
      next if res[1] == 0
      html += content_tag(:tr, content_tag(:td, res[0] + ' ' + content_tag(:td, res[1], :class => 'right')))
    end
    html
  end

end
