module UserExtension::Moderator
  def moderator?(site=Site.current)
    if site
      self.group_ids.include?(site.moderation_group_id)
    else
      false
    end
  end
end
