# Convenience methods making it easier to deal with week calculations
# when working with the calendar.
class Week
  
  # Instantiates a date property
  def initialize(date)
    @date = date
  end
  
  # Returns a DateTime representing the first day of the week for this week's date 
  def first_day_in_week
    @date - @date.cwday + 1
  end
 
end