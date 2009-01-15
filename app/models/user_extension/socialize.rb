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
        :finder_sql => 'SELECT users.* FROM users WHERE users.id IN (#{peer_id_cache.to_sql})' do
            # will_paginate bug: Association with finder_sql raises TypeError
            #  http://sod.lighthouseapp.com/projects/17958/tickets/120-paginate-association-with-finder_sql-raises-typeerror#ticket-120-5
            def find(*args)
              options = args.extract_options!
              sql = @finder_sql
      
              sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
              sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      
              User.find_by_sql(sql)
            end
          end  
      
      # discussion
      has_one :discussion, :as => :commentable
      #has_many :discussions, :through => :user_relations

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
    
  ## STATUS / WALL
  
  # returns the users current status by returning his latest status_posts.body
  def current_status
    self.discussion.posts.find_all_by_type('StatusPost').last.body rescue nil
  end

  ## CONTACTS

  # this should be the ONLY way that contacts are created.
  # as a side effect of the FriendActivity created when a contact is added, 
  # profiles will be created for self if they do not already exist. 
  def add_contact!(other_user, type=nil)
    unless self.contacts.find_by_id(other_user.id)
      self.contacts << other_user
      self.contacts.reset
      self.update_contacts_cache
    end
    unless other_user.contacts.find_by_id(self.id)
      other_user.contacts << self
      other_user.contacts.reset
      other_user.update_contacts_cache
    end
  end

  # this should be the ONLY way contacts are deleted
  def remove_contact!(other_user, type=nil)    
    if self.contacts.find(other_user.id)
      self.contacts.delete(other_user)
      self.update_contacts_cache
    end
    if other_user.contacts.find(self.id)
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

  ## Discussions
  
  def ensure_discussion
    unless self.discussion
      self.discussion = Discussion.create()
      self.discussion.user = self
    end
    self.discussion
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
