class UserRelationObserver < ActiveRecord::Observer

  def before_save(contact)
    # TODO: uncomment this when type is actually set!
    #return unless contact.type == 'Friendship' and contact.type_changed?
    if activity = FriendActivity.find_twin(contact.user, contact.partner)
      key = activity.key
    else
      key = rand(Time.now)
    end
    FriendActivity.create!(:user => contact.user, :other_user => contact.partner, :key => key)
  end

end

