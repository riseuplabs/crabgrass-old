module UserExtension::Moderator

  def moderator?(site=Site.current)
    site && self.group_ids.include?(site.moderation_group_id)
  end

  def moderates?(site=Site.current)
    moderator? or self.groups.moderating.any?
  end

  def may_moderate?(entity)
    return true if moderator?
    page = entity if entity.is_a?(Page)
    page = entity.discussion.page if entity.is_a?(Post)
    moderated_group_ids=Group.with_admin(self).moderated.map(&:id)
    return false unless moderated_group_ids.any?
    conditions = "group_id IN (#{moderated_group_ids})"
    page.group_participations.find(:first, :conditions => conditions)
  end
end
