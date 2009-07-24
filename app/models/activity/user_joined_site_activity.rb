class UserJoinedSiteActivity < UserJoinedGroupActivity

  def description(view=nil)
    "{user} has joined {group}"[
      :activity_user_joined_site, {
        :user => user_span(:user),
        :group => group_span(:group)
      }
    ]
  end

end
