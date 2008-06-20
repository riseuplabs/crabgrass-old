require 'poll/poll'

class Tool::RateMany < Page

  controller 'rate_many'
  model Poll
  icon 'rate-many.png'
  class_display_name 'approval vote'
  class_description "Approve or disapprove of each possibility."
  class_group 'poll'
    
  def initialize(*args)
    super(*args)
    self.data = Poll.new
  end
  
end
