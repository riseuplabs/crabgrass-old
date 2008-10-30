#
# Adapted from acts_as_rateable
#

class Rating < ActiveRecord::Base
  belongs_to :rateable, :polymorphic => true
  
  belongs_to :user
  
  # Helper class method to lookup all ratings assigned
  # to all rateable types for a given user.
  def self.find_ratings_by_user(user)
    find(:all,
      :conditions => ["user_id = ?", user.id],
      :order => "created_at DESC"
    )
  end

  named_scope :with_rating, lambda {|rating|
    { :conditions => ['rating = ?', rating] }
  }
  named_scope :by_user, lambda {|user|
    { :conditions => ['user_id = ?', user.id] }
  }

end

