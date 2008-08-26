module TimeHelper

  # Our goal here it to automatically display the date in the way that
  # makes the most sense. Elusive, i know. If an array of times is passed in
  # we display the newest one. 
  # Here are the current options:
  #   4:30PM    -- time was today
  #   Wednesday -- time was within the last week.
  #   Mar/7     -- time was in the current year.
  #   Mar/7/07  -- time was in a different year.
  # The date is then wrapped in a label, so that if you hover over the text
  # you will see the full details.
  def friendly_date(*times)
    return nil unless times.any?

    time  = times.compact.max
    today = Time.zone.today
    date  = time.to_date
    
    if date == today
      str = time.strftime("%I:%M<span style='font-size: 80%'>%p</span>")
    elsif today > date and (today-date) < 7
      str = time.strftime("%A")
    elsif date.year != today.year
      str = date.strftime("%d/%b/%Y")
    else
      str = date.strftime('%d/%b')
    end
    "<label title='#{ full_time(time) }'>#{str}</label>"
  end
  
  # formats a time, in full detail
  # for example: Sunday July/3/2007 2:13PM PST
  def full_time(time)
    time.strftime('%a %b %d %H:%M:%S %Z %Y')
  end

#  def to_local(time)
#    Time.zone.utc_to_local(time)
#  end
    
  def to_utc(time)
    Time.zone.local_to_utc(time)
  end

  def local_now
    Time.zone.now
  end

  def after_day_start?(time)
    local_now.at_beginning_of_day < time
  end
  
  def after_yesterday_start?(time)
    local_now.yesterday.at_beginning_of_day < time
  end

  def after_week_start?(time)
    (local_now.at_beginning_of_day - 7.days) < time
  end
  
  ##############################################
  ## UI helpers

  def calendar_tag(field_id, date=nil)
    include_calendar_tags
    calendar_date_select_tag( date ? date.to_date.to_formatted_s( :long ) : nil )
  end

  def include_calendar_tags
    unless @calendar_tags_included
      @calendar_tags_included = true
      content_for :end_tags do
        calendar_date_select_includes "default"
      end
    end
  end

end

