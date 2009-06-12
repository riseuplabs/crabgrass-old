class GroupObserver < ActiveRecord::Observer

  def before_destroy(group)
    key = rand(Time.now)
    group.users.each do |recipient|
      GroupDestroyedActivity.create!(:groupname => group.name, :recipient => recipient, :destroyed_by => group.destroyed_by, :key => key)
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
  
    if User.current and !group.is_a?(Network)
      group.add_user!(User.current)
    end
  end

end

