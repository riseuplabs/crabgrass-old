class MembershipObserver < ActiveRecord::Observer

  def after_create(membership)
    key = rand(Time.now)
    return if membership.group_id == Site.current.try.network_id
    UserJoinedGroupActivity.create!(:user => membership.user, :group => membership.group, :key => key)
    GroupGainedUserActivity.create!(:user => membership.user, :group => membership.group, :key => key)
  end

  def after_destroy(membership)
    unless membership.skip_destroy_notification
      key = rand(Time.now)
      if membership.group.site
        UserLeftSiteActivity.create!(:user => membership.user, :group => membership.group, :key => key)
      else
        UserLeftGroupActivity.create!(:user => membership.user, :group => membership.group, :key => key)
      end
      GroupLostUserActivity.create!(:user => membership.user, :group => membership.group, :key => key)
    end
  end

end
