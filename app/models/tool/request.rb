require 'poll/poll'

class Tool::Request < Page
  
  controller 'request'
  model      Poll::Poll
  icon       'bullhorn.png'
  internal?   true
  class_group 'request'
  
  # update the resolved status of all linked pages if a request
  # has its resolved status changed.
  after_save :update_resolved  
  def update_resolved
    if resolved_modified? and links.any?
      links.each do |page|
        page.update_attribute(:resolved, self.resolved?)
      end 
    end
  end
  
end

