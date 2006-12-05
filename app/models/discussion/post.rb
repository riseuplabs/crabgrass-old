class Post < ActiveRecord::Base

  ## associations ############################################
  
  belongs_to :discussion, :counter_cache => true
  belongs_to :user

  ## attributes #############################################
  
#  format_attribute :body
  attr_accessible :body
  
  ## validations ############################################

  validates_presence_of :discussion_id, :user_id, :body
  
  ## callbacks ##############################################
    
#  before_create { |r| r.forum_id = r.topic.forum_id }
#  after_create  { |r| Topic.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', r.created_at, r.user_id, r.id], ['id = ?', r.topic_id]) }
#  after_destroy { |r| t = Topic.find(r.topic_id) ; Topic.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', t.posts.last.created_at, t.posts.last.user_id, t.posts.last.id], ['id = ?', t.id]) if t.posts.last }

  ## methods ################################################

  def editable_by?(user)
    true
    #user && (user.id == user_id || discussion.page.admins.include?(user))
  end
  
end
