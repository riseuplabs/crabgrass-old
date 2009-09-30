class ModeratedPage < ModeratedFlag 

  belongs_to :page, :foreign_key=>'foreign_id'

  def foreign
    self.page
  end

  def mark_vetted
    self.page.update_attribute(:vetted, true)
  end

  def undelete
    self.page.update_attribute(:flow, nil)
    self.deleted_at = nil;
    self.save!
  end

end
