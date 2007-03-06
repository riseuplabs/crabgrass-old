require 'poll/poll'

class Tool::RateMany < Page

  controller 'polls'
  model Poll::Poll
  icon 'check.png'
  tool_type 'poll/rate many'
  
end
