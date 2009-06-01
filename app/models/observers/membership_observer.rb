class MembershipObserver < ActiveRecord::Observer

  def after_create(membership)
    key = rand(Time.now)
    if membership.group.site
      UserJoinedSiteActivity.create!(:user => membership.user, :group => membership.group, :key => key)
    else
      UserJoinedGroupActivity.create!(:user => membership.user, :group => membership.group, :key => key)
    end
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
