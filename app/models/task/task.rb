class Task::Task < ActiveRecord::Base
  
  belongs_to :task_list 
  has_and_belongs_to_many :users, :foreign_key => 'task_id'
  acts_as_list :scope => :task_list
  format_attribute :description
  
  def group_name
    task_list.page.group_name
  end
  
end
