class MakeSayPostsPrivate < ActiveRecord::Migration
  def self.up
    # this migration changes the access level of say posts to 'default' (2)
    # say posts exist in the posts table as well as in the activities table
    status_posts = StatusPost.find(:all)
    status_posts.each do |spost|
      wall_msg = MessageWallActivity.find_by_related_id(spost.id)
      next if wall_msg.nil?
      wall_msg.update_attributes!(:access => 2)
    end
  end

  def self.down
    # make 'say' posts public (3) again.
    status_posts = StatusPost.find(:all)
    status_posts.each do |spost|
      wall_msg = MessageWallActivity.find_by_related_id(spost.id)
      wall_msg.update_attributes!(:access => 3)
    end
  end
end
