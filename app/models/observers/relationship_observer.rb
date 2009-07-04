class RelationshipObserver < ActiveRecord::Observer

  def after_create(relationship)
    if relationship.type == "Friendship"
      if activity = FriendActivity.find_twin(relationship.user, relationship.contact)
        key = activity.key
      else
        key = rand(Time.now)
      end
      FriendActivity.create!(:user => relationship.user, :other_user => relationship.contact, :key => key)
    end
  end

  # i think perhaps it is unneccesary to create a new UnreadActivity each time
  # a new private post is created, since there will already be a private post
  # activity, and we will update the UnreadActivity when the user views the post.

  def after_save(relationship)
    if relationship.unread_count_changed?
      UnreadActivity.create(:user => relationship.user, :author => relationship.contact)
    end
  end

end

