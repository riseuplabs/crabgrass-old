=begin

Everything to do with user <> user relationships should be here.

=end

module UserExtension::Socialize
  def self.included(base)
    base.instance_eval do
  
      serialize_as IntArray, :friend_id_cache, :foe_id_cache

      initialized_by :update_contacts_cache,
        :friend_id_cache, :foe_id_cache
      
      # (peer_id_cache defined in UserExtension::Organize)
      has_many :peers, :class_name => 'User',
        :finder_sql => 'SELECT users.* FROM users WHERE users.id IN (#{peer_id_cache.to_sql})'

      has_and_belongs_to_many :contacts,
        {:class_name => "User",
        :join_table => "contacts",
        :association_foreign_key => "contact_id",
        :foreign_key => "user_id",
        :uniq => true} do
          def online
            find( :all, 
              :conditions => ['users.last_seen_at > ?',10.minutes.ago],
              :order => 'users.last_seen_at DESC' )
          end
      end

    end
  end

  ## CONTACTS

  # this should be the ONLY way that contacts are created
  def add_contact!(other_user, type=nil)
    unless self.contacts.find_by_id(other_user.id)
      Contact.create!(:user => self, :contact => other_user, :type => type)
      self.contacts.reset
      self.update_contacts_cache
    end
    unless other_user.contacts.find_by_id(self.id)
      Contact.create!(:user => other_user, :contact => self, :type => type)
      other_user.contacts.reset
      other_user.update_contacts_cache
    end
  end

  # this should be the ONLY way contacts are deleted
  def remove_contact!(other_user)
    if self.contacts.find_by_id(other_user.id)
      self.contacts.delete(other_user)
      self.update_contacts_cache
    end
    if other_user.contacts.find_by_id(self.id)
      other_user.contacts.delete(self)
      other_user.update_contacts_cache
    end
  end
  
  ## PERMISSIONS

  def may_be_pestered_by?(user)
    begin
      may_be_pestered_by!(user)
    rescue PermissionDenied
      false
    end
  end
  
  def may_be_pestered_by!(user)
    # TODO: perhaps being someones friend or peer does not automatically
    # mean that you can pester them. It should all be based on the profile?
    if friend_of?(user) or peer_of?(user) or profiles.visible_by(user).may_pester?
      return true
    else
      raise PermissionDenied.new('You not allowed to share with %s'[:pester_denied] % self.name)
    end
  end

  def may_pester?(entity)
    entity.may_be_pestered_by? self
  end
  def may_pester!(entity)
    entity.may_be_pestered_by! self
  end

  ## RELATIONSHIPS

  def stranger_to?(user)
    !peer_of?(user) and !contact_of?(user)
  end
  
  def peer_of?(user)
    id = user.instance_of?(Integer) ? user : user.id
    peer_id_cache.include?(id)  
  end
  
  def friend_of?(user)
    id = user.instance_of?(Integer) ? user : user.id
    friend_id_cache.include?(id)
  end
  alias :contact_of? :friend_of?
  
  def relationship_to(user)
    relationships_to(user).first
  end
  def relationships_to(user)
    return :stranger unless user
    (@relationships ||= {})[user.login] ||= get_relationships_to(user)
  end
  def get_relationships_to(user)
    ret = []
    ret << :friend   if friend_of?(user)
    ret << :peer     if peer_of?(user)
#   ret << :fof      if fof_of?(user)
    ret << :stranger if ret.empty?
    ret
  end
end
