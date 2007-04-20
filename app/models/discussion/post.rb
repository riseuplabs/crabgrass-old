class Post < ActiveRecord::Base

  ## associations ############################################
  
  belongs_to :discussion, :counter_cache => true
  belongs_to :user

  ## attributes #############################################
  
  format_attribute :body
  attr_accessible :body
  
  ## validations ############################################

  validates_presence_of :discussion_id, :user_id, :body  

  ## methods ################################################

  def editable_by?(user)
    true
  end
  
  # used for default group, if present, to set for any embedded links
  def group_name
    discussion.page.group_name
  end
  
end
