class Task::TaskList < ActiveRecord::Base
  
  # destroy() freaks out if we use :delete_all, so we use :destroy
  has_many :tasks, :order => "position", :dependent => :destroy, :include => :users
  # :class_name => 'Task::Task',
  # 
  has_many :completed, :class_name => 'Task',
    :order => "position", :conditions => ['completed = ?', true], :include => :users
    
  has_many :pending, :class_name => 'Task',
    :order => "position", :conditions => ['completed = ?', false], :include => :users
  
  has_many :pages, :as => :data
  def page; pages.first; end
  
end