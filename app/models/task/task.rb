class Task::Task < ActiveRecord::Base
  
  belongs_to :task_list, :class_name => 'Task::TaskList', :foreign_key => 'task_list_id'
  has_and_belongs_to_many :users, :foreign_key => 'task_id'
  acts_as_list :scope => :task_list
  format_attribute :description
  
  def group_name
    task_list.page.group_name
  end

  def completed=(is_completed)
    if is_completed
      self.completed_at = Time.now
    else
      self.completed_at = nil
    end
  end

  def completed
    completed_at != nil && completed_at < Time.now
  end
  alias :completed? :completed

  def past_due?
    !completed? && due_at && due_at.to_date < Date.today
  end
  alias :overdue? :past_due?
  
end
