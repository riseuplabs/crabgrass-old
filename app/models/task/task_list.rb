class Task::TaskList < ActiveRecord::Base
  has_many :tasks
  has_many :pages, :as => :data
end