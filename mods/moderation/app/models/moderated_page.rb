class ModeratedPage < ModeratedFlag 

  belongs_to :page, :foreign_key=>'foreign_id'

  def foreign
    self.page
  end

end
