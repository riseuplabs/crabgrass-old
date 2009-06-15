class AddStudentIdsToUserCache < ActiveRecord::Migration
  def self.up
    add_column :users, 'student_id_cache', :binary, :limit => 512

    say "updating membership_cache for: "
    User.find(:all).each do |user|
      user.update_membership_cache
      say "#{user.login}, "
    end
    say "done updating membership_cache.\n"

  end

  def self.down
    remove_column :users, 'student_id_cache'
  end
end
