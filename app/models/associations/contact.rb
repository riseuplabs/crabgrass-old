# user to user relationship

class Contact < ActiveRecord::Base
  belongs_to :user
  belongs_to :contact, :class_name => 'User', :foreign_key => :contact_id
  belongs_to :discussion
  
   #STI wont' work with HABTM associations
   before_update :set_sti_type
   def set_sti_type
     self.type = self.class.to_s
   end
end
