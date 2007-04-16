class Task::TaskList < ActiveRecord::Base
  has_many :tasks, :order => "position", :dependent => :delete_all, :include => :users
  
  has_many :completed, :class_name => 'Task', :order => "position", :conditions => ['completed = ?', true], :include => :users
  has_many :pending, :class_name => 'Task', :order => "position", :conditions => ['completed = ?', false], :include => :users

  # do
  #  def completed
  #    find(:all, :conditions => ['completed = ?', true])
  #  end
  #end
  #  def pending
  #    find(:all, :conditions => ['completed = ?', false])
  #  end
  #end
  
  has_many :pages, :as => :data
  def page; pages.first; end
end