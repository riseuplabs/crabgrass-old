#
# the join table for assets that are in photo galleries.
# 

class Showing < ActiveRecord::Base
  belongs_to :gallery
  belongs_to :asset

  acts_as_list :scope => :gallery
  
  belongs_to :discussion
  
  def comments
    unless discussion
      create_discussion
    end
    discussion.posts
  end
  
  alias :image :asset
end
