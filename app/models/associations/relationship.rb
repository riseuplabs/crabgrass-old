# user to user relationship

class Relationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :contact, :class_name => 'User', :foreign_key => :contact_id
  belongs_to :discussion, :dependent => :destroy
 
  
end
