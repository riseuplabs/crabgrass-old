module UserParticipationExtension::PageHistory 
  def self.included(base)
    base.class_eval do
    end
  end

  def start_watching?
    self.watch_changed? && self.watch == true
  end

  def stop_watching?
    self.watch_changed? && self.watch != true
  end

  def star_added?
    self.star_changed? && self.star == true
  end
  
  def star_removed?
    self.star_changed? && self.star != true
  end

  def granted_user_full_access?
    self.access_changed? && self.access_sym == :admin
  end

  def granted_user_write_access?
    self.access_changed? && self.access_sym == :edit
  end

  def granted_user_read_access?
    self.access_changed? && self.access_sym == :view
  end

  def cleared_user_access?
    self.access_changed? && self.access_sym == nil
  end
end
