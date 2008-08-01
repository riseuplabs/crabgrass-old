class TasksUser < ActiveRecord::Base
  belongs_to :user
end

class CreateTaskParticipationsAndCopyDataFromTaskUsers < ActiveRecord::Migration

  def self.up
    create_table :task_participations do |t|
      t.boolean :watching
      t.boolean :waiting
      t.boolean :assigned
      
      t.references :user
      t.references :task
    end

    ActiveRecord::Base.record_timestamps = false
    TaskParticipation.reset_column_information
    TasksUser.find(:all).each do |tuser|
      tpart = TaskParticipation.create( :assigned => true, :user_id => tuser.user_id, :task_id => tuser.task_id )
      tpart.save!
    end
    
    drop_table :tasks_users
  end

  def self.down
    create_table :tasks_users do |t|
      t.references :user
      t.references :task
    end
    
    ActiveRecord::Base.record_timestamps = false
    TasksUser.reset_column_information
    TaskParticipation.find(:all).each do |tpart|
      tuser = TasksUser.create( :user_id => tpart.user_id, :task_id => tpart.task_id )
      tuser.save!
    end

    drop_table :task_participations
  end
end
