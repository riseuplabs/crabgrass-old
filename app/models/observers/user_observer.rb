class UserObserver < ActiveRecord::Observer

  def before_create(user)
    user.build_wall_discussion
  end

  def before_destroy(user)
    key = [user['id'], user.login].hash
    (user.peers_before_destroy + user.contacts_before_destroy).each do |recipient|
      UserDestroyedActivity.create!(:username => user.name, :recipient => recipient, :key => key)
    end
  end

end
