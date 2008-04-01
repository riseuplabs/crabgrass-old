class Group < ActiveRecord::Base
  acts_as_modified :clear_after_save => true
end
