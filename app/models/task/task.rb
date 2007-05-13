class Task::Task < ActiveRecord::Base
  
  belongs_to :task_list 
  has_and_belongs_to_many :users
  acts_as_list :scope => :task_list
  format_attribute :description
  
  def group_name
    task_list.page.group_name
  end
  
  #def user_id=(id)
  #  u = User.find_by_id(id)
  #  users.clear
  #  users << u if u
  #end
  #def user_id
  #  users.first.id if users.any?
  #end
  #def user
  #  users.first if users.any?
  #end
  
end
