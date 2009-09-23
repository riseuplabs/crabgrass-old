#
# this is a generic moderation model
#

class ModeratedFlag < ActiveRecord::Base

  belongs_to :foreign, :polymorphic => true
  belongs_to :user

  def add(current_user_id, options)
    self.reason_flagged = options[:reason] if options[:reason]
    self.comment = options[:comment] if options[:comment]
    self.save!
  end

  def remove(current_user)
    if self.find_by_user(current_user).first
      self.destroy
#??? what is this??  self.foreign.update_attribute(:yuck_count, self.foreign.ratings.with_rating(YUCKY_RATING).count)
    end
  end

  named_scope :with_rating, lambda {|rating|
    { :conditions => ['rating = ?', rating] }
  }
  named_scope :by_user, lambda {|user|
    { :conditions => ['user_id = ?', user.id] }
  }

end
