require 'poll/poll'

class Tool::RateMany < Page

  controller 'rate_many'
  model Poll::Poll
  icon 'shirt.png'
  tool_type 'poll/rate many'
  
  def initialize(*args)
    super(*args)
    self.data = Poll::Poll.new
  end
  
end
