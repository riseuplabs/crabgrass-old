class GroupHadUserRemovedActivity < GroupLostUserActivity
  validates_presence_of :extra

  alias_attr :admin, :extra

  def description(view=nil)
    "{admin} has removed {user} from {group_type} {group}"[
       :activity_user_removed_from_group, {
         :admin => admin,
         :user => user_span(:user),
         :group_type => group_class(:group),
         :group => group_span(:group)
       }
    ]
  end
end
