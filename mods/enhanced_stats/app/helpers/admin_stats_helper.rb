module AdminStatsHelper

  def add_calendar_js(trigger, el)
    "var calendar = Calendar.setup( { triggerElement: '#{trigger}', dateField: '#{el}' });"
  end

end
