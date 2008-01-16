class Task::TaskList < ActiveRecord::Base
  
  # destroy() freaks out if we use :delete_all, so we use :destroy
  has_many :tasks, :class_name => 'Task::Task',
    :order => "position", :dependent => :destroy, :include => :users

  has_many :completed, :class_name => 'Task::Task',
    :order => "position", :conditions => ['completed = ?', true], :include => :users
    
  has_many :pending, :class_name => 'Task::Task',
    :order => "position", :conditions => ['completed = ?', false], :include => :users
  
  has_many :pages, :as => :data
  def page; pages.first; end
  
end
