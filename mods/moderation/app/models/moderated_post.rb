#
# DEPRECATED
#
# This class has been obsoleted by using a polymorphic approach.
# It's left here to avoid class not found errors during earlier
# migrations.

class ModeratedPost < ModeratedFlag

  belongs_to :post, :foreign_key => 'flagged_id'

  def foreign
    self.post
  end

end
