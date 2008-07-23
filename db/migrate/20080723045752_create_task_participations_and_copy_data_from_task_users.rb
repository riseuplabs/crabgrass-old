class AddWatchingAndWaitingToTaskUsers < ActiveRecord::Migration
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
    TasksUser.find(:all).each_with_index do |tuser, i|
      tpart = TaskParticipation.create( :assigned => true, :user => tuser.user, :task => tuser.task )
      tpart.save!
    end
    
  end

  def self.down
    drop_table :task_participations
  end
end
