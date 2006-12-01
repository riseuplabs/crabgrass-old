# user to user relationship

class Contacts < ActiveRecord::Base
  belongs_to :user
  belongs_to :contact,
    :class_name => 'User'
    
end
