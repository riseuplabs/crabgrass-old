class ModeratedPost < ModeratedFlag 

  belongs_to :post, :foreign_key => 'foreign_id'

  def foreign
    self.post
  end

  def trash
    self.post.delete
    ModeratedPost.trash_all(self.foreign_id)
  end

  def undelete
    self.post.undelete
    ModeratedPost.undelete_all(self.foreign_id)
  end

end
