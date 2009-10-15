class ModeratedPage < ModeratedFlag 

  belongs_to :page, :foreign_key=>'foreign_id'

  def foreign
    self.page
  end

  def mark_vetted
    self.page.update_attribute(:vetted, true)
  end

  def undelete
    self.page.undelete
    ModeratedPage.undelete_all(self.foreign_id)
  end

  def trash
    self.page.delete
    ModeratedPage.trash_all(self.foreign_id)
  end

end
