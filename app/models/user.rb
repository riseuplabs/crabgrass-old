class User < AuthenticatedUser

  ### attributes
  
  cattr_accessor :current
  
  ### associations
  
  has_many :memberships
  has_many :groups,
    :through => 'memberships'

  has_many :user_participations
  has_many :nodes, :through => 'user_participations' do
	def urgent
	  find(:all, :conditions => 'deadline > now()', :order => 'deadline' )
	end
  end
  
  has_many :urgent_nodes,
    :condition => 'deadline > now()',
	:order => 'deadline',
	:through => 'visits'
  
  has_many :unread_nodes,
    :condition => 'read_at < updated_at',
    :order => 'updated_at',
	:through => 'visits',
    :class_name => 'Node'

  has_many :watched_nodes,
    :condition => 'watch = 1',
    :order => 'updated_at',
	:through => 'visits',
    :class_name => 'Node'

#  has_many :nodes_created 
#    :class_name => "Node"

  has_and_belongs_to_many :contacts,
    :class_name => "User",
    :join_table => "contacts",
    :association_foreign_key => "contact_id",
    :foreign_key => "user_id",
    :after_add => :reciprocate_add,
    :after_remove => :reciprocate_remove
 
  has_many :messages
 
  belongs_to :picture
  
  ### validations
  
  validates_presence_of 'name', 'username'
  
  ### callbacks
  
  # if i add you as a contact, then you get
  # me as a contact as well.
  def reciprocate_add(other_user)
    other_user.contacts << self unless other_user.contacts.include?(self)
  end
  
  # if i remove you as a contact, then you 
  # remove me as a contact as well.  
  def reciprocate_remove(other_user)
    other_user.contacts.delete(self) rescue nil
  end

end
