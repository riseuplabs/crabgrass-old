module EventTimeHelper

  # greenchange_note: Events have their own timezone so we need our
  # own event time helper in order to use the events timezone and not
  # the one in 'time_helper' because that is keyed off a system wide
  # before_filter which sets the timezone to the current users 
  # TODO: -- This could eventually be used to refactor
  # 'time_helper.rb' to take optional 'zone' parameters to override
  # the system wide user timezone
  
  # formats a time, in full detail
  # for example: Sunday July/3/2007 2:13PM
  def event_full_time(time, zone)
    time = event_to_local(time,zone)
    time.loc('%A %d %b %Y %I:%M %p')
  end

  def event_date_only(time, zone)
    time = event_to_local(time,zone)
    time.loc('%A %d %b %Y')
  end

  def long_date(date, zone)
    date = event_to_local(date,zone)
    date.loc('%A %B %d, %G')
  end

  def event_on_day(event, day)
    day.loc('%Y-%m-%d') >= event_to_local(event.starts_at.to_time,event.data.time_zone).to_date.loc('%Y-%m-%d') and day.loc('%Y-%m-%d') <= event_to_local(event.ends_at.to_time,event.data.time_zone).to_date.loc('%Y-%m-%d') 
  end

  def event_to_local(time, zone)
    TzTime.new(TimeZone[zone].utc_to_local(time), TimeZone[zone])
  end
    
  def event_to_utc(time, zone)
    TzTime.new(time,TimeZone[zone]).utc
  end

  def event_local_now(zone)
    TimeZone[zone].now
  end

#   def after_local_day_start?(utc_time)
#     local_now.at_beginning_of_day < to_local(utc_time)
#   end
  
#   def after_local_yesterday_start?(utc_time)
#     local_now.yesterday.at_beginning_of_day < to_local(utc_time)
#   end

#   def after_local_week_start?(utc_time)
#     (local_now.at_beginning_of_day - 7.days) < to_local(utc_time)
#   end
  
end

