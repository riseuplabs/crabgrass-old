require 'poll/poll'

class Tool::RateMany < Page

  controller 'rate_many'
  model Poll::Poll
  icon 'rate-many.png'
  class_display_name 'straw poll'
  class_description "An informal poll of people's preferences."
  class_group 'poll'
    
  def initialize(*args)
    super(*args)
    self.data = Poll::Poll.new
  end
  
end
