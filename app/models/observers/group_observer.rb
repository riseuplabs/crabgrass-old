class GroupObserver < ActiveRecord::Observer

  def before_destroy(group)
    key = rand(Time.now)
    group.users.each do |recipient|
      GroupDestroyedActivity.create!(:groupname => group.name, :recipient => recipient, :destroyed_by => group.destroyed_by, :key => key)
      Mailer.deliver_group_destroyed_notification(recipient, group)
    end
  end

  def after_create(group)
    key = rand(Time.now)
    GroupCreatedActivity.create!(:group => group, :user => group.created_by, :key => key)

    if group.created_by
      UserCreatedGroupActivity.create!(:group => group, :user => group.created_by, :key => key)
    end

    if Site.current
      Site.current.add_group!(group)
    end

    if User.current
      if !group.is_a?(Network) or (group.is_a?(Network) and !User.current.may?(:admin, group))
        group.add_user!(User.current)
      end
    end
  end

end

