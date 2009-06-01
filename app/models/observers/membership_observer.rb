class MembershipObserver < ActiveRecord::Observer

  def after_create(membership)
    key = rand(Time.now)
    UserJoinedGroupActivity.create!(:user => membership.user, :group => membership.group, :key => key)
    GroupGainedUserActivity.create!(:user => membership.user, :group => membership.group, :key => key)
  end

  def after_destroy(membership)
    unless membership.skip_destroy_notification
      key = rand(Time.now)
      UserLeftGroupActivity.create!(:user => membership.user, :group => membership.group, :key => key)
      GroupLostUserActivity.create!(:user => membership.user, :group => membership.group, :key => key)
    end
  end

end

