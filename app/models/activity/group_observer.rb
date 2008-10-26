class GroupObserver < ActiveRecord::Observer

  def before_destroy(group)
    group.users.each do |recipient|
      GroupDestroyedActivity.create!(:groupname => group.name, :recipient => recipient, :destroyed_by => group.destroyed_by)
    end
  end

  def after_create(group)
    key = rand(Time.now)
    GroupCreatedActivity.create!(:group => group, :user => group.created_by, :key => key)
    if group.created_by
      UserCreatedGroupActivity.create!(:group => group, :user => group.created_by, :key => key)
    end
  end

end

