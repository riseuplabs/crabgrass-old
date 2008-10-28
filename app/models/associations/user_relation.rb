class UserRelation < ActiveRecord::Base
  belongs_to :user, :foreign_key => "user_id", :class_name => "User"
  belongs_to :partner,   :foreign_key => "partner_id",   :class_name => "User"

  after_save :reverse_create!
  after_destroy :reverse_destroy!
  
  def reverse_create!    
    unless self.class.name.constantize.find_by_user_id_and_partner_id(self.partner_id,self.user_id)
      u = self.class.name.constantize.new()
      u.user_id = self.partner_id
      u.partner_id = self.user_id
      u.save
    end
   # UserRelation.create(:user_id => self.partner_id, :partner_id => self.user_id, :type => 'Friendship') unless UserRelation.find_by_user_id_and_partner_id_and_type(self.partner_id,self.user_id,"Friendship")
  end
  
  def reverse_destroy!
   if reverse_duplicate = find_reverse_duplicate
     reverse_duplicate.destroy
   end  
  end
  
  def find_duplicate
    UserRelation.find_by_user_id_and_partner_id_and_type(self.user_id, self.partner_id, self.type)
  end
  
  def find_reverse_duplicate
    UserRelation.find_by_user_id_and_partner_id_and_type(self.partner_id, self.user_id, self.type)
  end
end
