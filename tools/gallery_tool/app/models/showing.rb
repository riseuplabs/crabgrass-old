#
# the join table for assets that are in photo galleries.
# 

class Showing < ActiveRecord::Base
  belongs_to :gallery
  belongs_to :asset
  
  acts_as_list :scope => :gallery
  
  alias :image :asset
end
