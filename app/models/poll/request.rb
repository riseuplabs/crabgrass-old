class Poll::Request < Poll::Poll
  
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
  
  def approve(comment=nil)
    resolve 1, comment
    possible.action.execute
  end
  
  def reject(comment=nil)
    resolve 0, comment
  end
  
  private
  
  def resolve(value,comment)
    page.resolved = true
    possible.create_vote(:user => current_user, :value => value, :comment => comment)
    page.updated_by = current_user
    page.save
  end

end

