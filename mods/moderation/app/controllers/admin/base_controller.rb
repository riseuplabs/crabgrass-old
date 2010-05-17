class Admin::BaseController

  # to use with path_finder:
  def moderation_options
    current_user.moderator?(current_site) ?
      {} :
      options_for_groups(Group.with_admin(current_user).moderated)
  end
end
