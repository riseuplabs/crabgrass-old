module UserExtension::Moderator

  def moderator?(site=Site.current)
    site && self.group_ids.include?(site.moderation_group_id)
  end

  def moderates?(site=Site.current)
    moderator? or Group.with_admin(self).moderated.any?
  end

end
