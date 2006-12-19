# == Schema Information
# Schema version: 19
#
# Table name: users
#
#  id                        :integer(11)   not null, primary key
#  login                     :string(255)   
#  email                     :string(255)   
#  crypted_password          :string(40)    
#  salt                      :string(40)    
#  created_at                :datetime      
#  updated_at                :datetime      
#  remember_token            :string(255)   
#  remember_token_expires_at :datetime      
#  display_name              :string(255)   
#  time_zone                 :string(255)   
#  language                  :string(5)     
#

class User < AuthenticatedUser

  ### attributes
  
  # a class attr which is set to the currently logged in user
  cattr_accessor :current
  
  ### associations
 
  # relationship to groups
  has_and_belongs_to_many :groups, :join_table => :memberships
  
  # peers are users who share at least one group with us
  has_many :peers, :class_name => 'User', 
    :finder_sql => 'SELECT DISTINCT * FROM users INNER JOIN memberships ON users.id = memberships.user_id WHERE users.id != #{id} AND memberships.group_id IN (SELECT id FROM groups INNER JOIN memberships ON groups.id = memberships.group_id WHERE memberships.user_id = #{id})'
  
  # relationship to pages
  has_many :participations, :class_name => 'UserParticipation'
  has_many :pages, :through => :participations do
	def pending
	  find(:all, :conditions => ['resolved = ?',false], :order => 'happens_at' )
	end
  end
  
#  has_many :urgent_nodes,
#    :condition => 'deadline > now()',
#	:order => 'deadline',
#	:through => 'visits'
  
#  has_many :unread_nodes,
#    :condition => 'read_at < updated_at',
#    :order => 'updated_at',
#	:through => 'visits',
#   :class_name => 'Node'

#  has_many :watched_nodes,
#    :condition => 'watch = 1',
#    :order => 'updated_at',
#	:through => 'visits',
#    :class_name => 'Node'

  has_many :pages_created, 
    :class_name => "Page", :foreign_key => :created_by_id 

  has_many :pages_updated, 
    :class_name => "Page", :foreign_key => :updated_by_id 

  # relationship to other users
  has_and_belongs_to_many :contacts,
    :class_name => "User",
    :join_table => "contacts",
    :association_foreign_key => "contact_id",
    :foreign_key => "user_id",
    :after_add => :reciprocate_add,
    :after_remove => :reciprocate_remove
 
#  has_many :messages
 
#  belongs_to :picture
  
  ### validations
  
  validates_format_of :login, :with => /^[a-z0-9]+([-_\.]?[a-z0-9]+){1,17}$/
  
  ### callbacks
  
  # if i add you as a contact, then you get
  # me as a contact as well.
  def reciprocate_add(other_user)
    other_user.contacts << self unless other_user.contacts.include?(self)
  end
  
  # if i remove you as a contact, then you 
  # remove me as a contact as well.  
  def reciprocate_remove(other_user)
    other_user.contacts.delete(self) if other_user.contacts.include?(self)
  end
  
  ### public methods
  
  def to_param
    return login
  end

  def may?(perm, page)
    may!(perm,page) rescue false
  end
  
  def may!(perm, page)
    true
  end
  
end
