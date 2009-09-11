class FixUnsanitizedActivityMessages < ActiveRecord::Migration
  def self.up
    MessageWallActivity.paginated_each do |activity|
      activity.update_attribute(:extra, {:type => activity.extra[:type], :snippet => GreenCloth.new(Post.find(activity.related_id).body[0..140], 'page', [:lite_mode]).to_html})
    end

    PrivatePostActivity.paginated_each do |activity|
      activity.update_attribute(:extra, GreenCloth.new(Post.find(activity.related_id).body[0..140], 'page', [:lite_mode]).to_html)
    end    
  end

  def self.down
  end
end
