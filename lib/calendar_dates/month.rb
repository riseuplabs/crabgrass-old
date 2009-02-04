 class Month
    
    def initialize(date)
      @date = date
    end
    
    def >>
      return Month.new(@date >>1)
    end
    
    def first_day_in_month
      DateTime.new(@date.year, @date.month, 1)
    end
    
    def last_day_in_month
      startdate = first_day_in_month
      enddate = (startdate.>>1)-1
    end
    
    def day_in_month(day)
      first_day_in_month + day
    end
    
    def days_in_month
      days = []
      first_day_in_month.upto last_day_in_month do |day|
        days<<day.day
      end
      days
    end
    
    def first_in_month(dayname)
      first_day_in_month.upto day_in_month(7) do |day|
        if(day.strftime("%A") == dayname)
          return day
        end
      end    
    end
    
    def last_in_month(dayname)
      last_day_in_month.downto(last_day_in_month - 7) do |day|
        if(day.strftime("%A") == dayname)
          return day
        end
      end
    end
        
    def weeks_in_month
      weeks = []
      for day in days_in_month
        # keep adding weeks until we run out of days in the month
      end
    end
    
  end