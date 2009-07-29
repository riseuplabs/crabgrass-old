module UserExtension::Moderator
  def moderator?(site=nil)
    site ||= self.current_site
    if site
      self.group_ids.include?(site.moderation_group_id)
    else
      false
    end
  end
end
