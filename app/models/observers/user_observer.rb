class UserObserver < ActiveRecord::Observer

  def before_destroy(user)
    (user.peers + user.contacts).each do |recipient|
      UserDestroyedActivity.create!(:username => user.name, :recipient => recipient)
    end
  end

end
