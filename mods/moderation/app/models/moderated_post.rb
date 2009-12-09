class ModeratedPost < ModeratedFlag

  belongs_to :post, :foreign_key => 'flagged_id'

  def foreign
    self.post
  end

end
