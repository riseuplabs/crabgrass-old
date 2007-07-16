#
# add a user contact
#

class Actions::AddToContacts < Actions::Base

  def initialize(user1,user2)
    @uid1 = user1.id
    @uid2 = user2.id
  end
  
  def execute(page)
    user1 = User.find @uid1
    user2 = User.find @uid2
    user1.contacts << user2
  end
  
end
