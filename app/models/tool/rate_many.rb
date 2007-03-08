require 'poll/poll'

class Tool::RateMany < Page

  controller 'polls'
  model Poll::Poll
  icon 'shirt.png'
  tool_type 'poll/rate many'
  
end
