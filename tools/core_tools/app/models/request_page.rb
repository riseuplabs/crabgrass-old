class RequestPage < Page 
  internal?   true
  
  # update the resolved status of all linked pages if a request
  # has its resolved status changed.
  after_save :update_resolved  
  def update_resolved
    if resolved_changed? and links.any?
      links.each do |page|
        page.update_attribute(:resolved, self.resolved?)
      end 
    end
  end
  
end

