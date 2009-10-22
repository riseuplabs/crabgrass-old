class FixUnsanitizedActivityMessages < ActiveRecord::Migration
  def self.up
    MessageWallActivity.paginated_each do |activity|
      if post = Post.find_by_id(activity.related_id)
        activity.update_attribute(:extra, {:type => activity.extra[:type], :snippet => GreenCloth.new(post.body[0..140], 'page', [:lite_mode]).to_html})
      end
    end

    PrivatePostActivity.paginated_each do |activity|
      if post = Post.find_by_id(activity.related_id)
        activity.update_attribute(:extra, GreenCloth.new(post.body[0..140], 'page', [:lite_mode]).to_html)
      end
    end    
  end

  def self.down
  end
end
