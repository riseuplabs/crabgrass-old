class Task::Task < ActiveRecord::Base
  belongs_to :task_list 
  has_and_belongs_to_many :users
end