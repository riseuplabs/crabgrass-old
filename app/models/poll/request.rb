class Poll::Request < Poll::Poll
  
  def vote
    votes.first
  end
    
  # a shortcut to the first possible
  def action=(value)
    possible.action = value
  end
  
  # a shortcut to the first possible
  def name=(value)
    possible.name = value
  end
  def name
    possible.name
  end
  
  def approve(options)
    possible.action.execute
    resolve 1, options[:by], options[:comment]
  end
  
  def reject(options)
    resolve 0, options[:by], options[:comment]
  end
  
  private
  
  def resolve(value,user,comment)
    page.resolved = true
    possible.votes.create(:user => user, :value => value, :comment => comment)
    page.updated_by = user
    page.save
  end

end

