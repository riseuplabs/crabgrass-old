# == Schema Information
# Schema version: 24
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
#  avatar_id                 :integer(11)   
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
    :finder_sql => 'SELECT DISTINCT users.* FROM users INNER JOIN memberships ON users.id = memberships.user_id WHERE users.id != #{id} AND memberships.group_id IN (SELECT id FROM groups INNER JOIN memberships ON groups.id = memberships.group_id WHERE memberships.user_id = #{id})'
  
  # relationship to pages
  has_many :participations, :class_name => 'UserParticipation'
  has_many :pages, :through => :participations do
	def pending
	  find(:all, :conditions => ['resolved = ?',false], :order => 'happens_at' )
	end
  end
  
  belongs_to :avatar
  
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
  
  has_many :tags, :finder_sql => %q[
    SELECT DISTINCT tags.* FROM tags INNER JOIN taggings ON tags.id = taggings.tag_id
    WHERE taggings.taggable_type = 'Page' AND taggings.taggable_id IN
      (SELECT pages.id FROM pages INNER JOIN user_participations ON pages.id = user_participations.page_id
      WHERE user_participations.user_id = #{id})]
    
  ### validations
  
  validates_format_of :login, :with => /^[a-z0-9]+([-_\.]?[a-z0-9]+){1,17}$/
  
  ### callbacks
 
  def after_destroy
    avatar.destroy
  end
  
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
  
  # perm one of :view, :edit, :admin
  # this is still a basic stub.
  def may!(perm, page)
    upart = page.participation_for_user(self)
    return true if upart
    gparts = page.participation_for_groups(self.group_ids)
    return true if gparts.any?
    raise PermissionDenied
  end
  
  def add_page(page, attributes)
    # user_participations.build doesn't update the pages.users
    # until it is saved, which seems like a bug, so we use create
    page.user_participations.create attributes.merge(
       :page_id => page.id, :user_id => id,
       :resolved => page.resolved?)
  end
  
  def remove_page(page)
    page.users.delete(self)
  end
  
  # should be called when a user visits a page
  def viewed(page)
    party = page.participation_for_user(self)
    return unless party
    party.viewed_at = Time.now
    party.viewed = true
    party.save
  end
  
  # should be called when a user writes to a page
  # or resolves a page.
  # options:
  #  - resolved: user's participation is resolved with this page
  #  - all_resolved: everyone's participation is resolved.
  #
  def updated(page, options={})
    # create self's participation if it does not exist
    page.user_participations.build(:user_id => self.id) unless page.participation_for_user(self) 
  
    # update everyone's participation
    now = Time.now
    page.user_participations.each do |party|
      if party.user_id == self.id
        party.changed_at = now
        party.viewed_at = now
        party.viewed = true
        party.resolved = options[:resolved] || options[:all_resolved] || party.resolved?
      else
        party.resolved = options[:all_resolved] || party.resolved?
        party.viewed = false
      end
      party.save      
    end
    # this is unfortunate, because perhaps we have already just modified the page?
    # we should test here to see if we have already saved the page this request.
    page.resolved = options[:all_resolved] || page.resolved?
    page.updated_at = now
    page.save
  end
  
  # return an array of ids of all groups this user is a member of.
  # in the future, perhaps this will be cached in the session.
  # or perhaps :include groups when fetching current_user
  def group_ids
    groups.collect{|g|g.id}
  end
end
