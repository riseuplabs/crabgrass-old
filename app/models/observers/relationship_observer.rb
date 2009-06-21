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

end

