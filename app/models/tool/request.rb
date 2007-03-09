require 'poll/poll'

class Tool::Request < Page
   controller 'request'
   model      Poll::Poll
   icon       'alert.png'
   tool_type  'request'
   internal?   true
end

