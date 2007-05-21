require 'poll/poll'

class Tool::Request < Page
   controller 'request'
   model      Poll::Poll
   icon       'bullhorn.png'
   internal?   true
end

