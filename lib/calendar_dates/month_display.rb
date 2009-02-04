class MonthDisplay
  
  require 'calendar_dates/month.rb'
  
  def initialize(date)
    @date = date
    @month = Month.new(@date)
    @startdate = find_initial_day
    @enddate = @startdate + 41
  end
  
  def days
    monthdays = []
    @startdate.upto @enddate do |day|
      monthdays<<day
    end
    monthdays
  end
  
  def to_s
    s = ""
    s << "Month: " + "#{@date.strftime('%B')}" + " " + @date.year.to_s 
    s << " ::: "
    s << "Start display: " + @startdate.to_s
    s << " ::: "
    s << "End display: " + @enddate.to_s
  end
  
    
  # Any date we're given must be in a month.
  # 
  # Accordingly, for display purposes we should find the initial day of 
  # the month in question. Then we need to check if this happens to fall 
  # on a Sunday.  If it does, we're in business.  If not, we need
  # to find out the date of the previous Sunday, which is going to be 
  # the start date of the display.
  def find_initial_day
    if @month.first_day_in_month.wday == 0 
      initial_day = @month.first_day_in_month
    else
      go_back_days = @month.first_day_in_month.wday * -1
      initial_day = @month.first_day_in_month + go_back_days
    end
    initial_day
  end
end