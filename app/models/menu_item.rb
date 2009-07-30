class MenuItem < ActiveRecord::Base

  belongs_to :group
  acts_as_list :scope => :group

end
