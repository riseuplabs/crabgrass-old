class Task::Task < ActiveRecord::Base
  belongs_to :task_list 
  has_and_belongs_to_many :users
  acts_as_list :scope => :task_list
  
  def user=(u)
    u = User.find_by_id(u) if u.is_a? String
    users << u if u
  end
  def user
    users.first if users.any?
  end
  
end