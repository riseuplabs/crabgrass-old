module AdminStatsHelper

  def add_calendar_js(trigger, el)
    "var calendar = Calendar.setup( { triggerElement: '#{trigger}', dateField: '#{el}' });"
  end

  def show_results_for(collection)
    html = ''
    collection.each do |res|
      next if res[1] == 0
      html += content_tag(:li, res[0] + ' ' + content_tag(:span, res[1]))  
    end
    html
  end

end
