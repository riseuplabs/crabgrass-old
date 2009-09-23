module GroupParticipationExtension::PageHistory 
  def self.included(base)
    base.class_eval do
    end
  end

  def granted_group_full_access?
    self.access_changed? && self.access_sym == :admin
  end

  def granted_group_write_access?
    self.access_changed? && self.access_sym == :edit
  end

  def granted_group_read_access?
    self.access_changed? && self.access_sym == :view
  end

  def cleared_group_access?
    self.access_changed? && self.access_sym == nil
  end
end
