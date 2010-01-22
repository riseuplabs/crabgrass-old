#
# DEPRECATED: This class is going away and be replaced with
#             moderated_flags which are polymorphic.

class ModeratedPage < ModeratedFlag

  belongs_to :page, :foreign_key=>'flagged_id'

  def foreign
    self.page
  end

end
