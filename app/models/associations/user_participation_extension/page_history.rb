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
end
