class AddWallDiscussionDataToUsers < ActiveRecord::Migration
  def self.up
    User.all.each do |user|
      user.create_wall_discussion if user.wall_discussion.blank?
    end
  end

  def self.down
  end
end
