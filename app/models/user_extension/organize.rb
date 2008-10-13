=begin

Everything to do with user <> group relationships should be here.

How to use
-----------
 
There are two valid ways to establish membership between user and group:

group.memberships.create :user => user
user.memberships.create :group => group

Other methods should not be used!

Membership information is cached in the user table. It will get
automatically updated whenever membership is created or destroyed. In cases
of indirect membership (all_groups) the database is correctly updated
but the in-memory object will need to be reloaded if you want the new data.

=end

module UserExtension::Organize
  def self.included(base)
    base.instance_eval do
      has_many :memberships, :foreign_key => 'user_id',
        :dependent => :destroy,
        :before_add => :check_duplicate_memberships,
        :after_add => [
          :update_membership_cache,
          :clear_peer_cache_of_my_peers,
          :increment_group_version],
        :after_remove => [
          :clear_peer_cache_of_my_peers,
          :update_membership_cache,
          :increment_group_version]
      
      has_many :groups, :foreign_key => 'user_id', :through => :memberships do
        def <<(*dummy)
          raise Exception.new("don't call << on user.groups");
        end
        def delete(*records)
          super(*records)
          records.each do |group|
            group.increment!(:version)
          end
          proxy_owner.clear_peer_cache_of_my_peers
          proxy_owner.update_membership_cache
        end
        def normals
          self.select{|group|group.normal?}
        end
        def networks
          self.select{|group|group.network?}
        end
        def committees
          self.select{|group|group.committee?}
        end
      end
        
      # all groups, including groups we have indirect access
      # to (ie committees and networks)
      has_many :all_groups, :class_name => 'Group', 
        :finder_sql => 'SELECT groups.* FROM groups WHERE groups.id IN (#{all_group_id_cache.to_sql})' do
        def normals
          self.select{|group|group.normal?}
        end
        def networks
          self.select{|group|group.network?}
        end
        def committees
          self.select{|group|group.committee?}
        end
      end
      
      serialize_as IntArray,
        :direct_group_id_cache, :all_group_id_cache, :peer_id_cache

      initialized_by :update_membership_cache,
        :direct_group_id_cache, :all_group_id_cache, :peer_id_cache


      #this seems to be the only way to override the A/R created method
      remove_method :all_group_ids
      remove_method :group_ids
    end
  end

  # alias for the cache.
  def group_ids
    self.direct_group_id_cache
  end
  
  # alias for the cache
  def all_group_ids
    self.all_group_id_cache
  end
    
  # is this user a member of the group?
  # (or any of the associated groups)
  def member_of?(group)
    if group.is_a? Array
      group.detect{|g| member_of?(g)}
    elsif group.is_a? Integer
      all_group_ids.include?(group)
    elsif group.is_a? Group
      all_group_ids.include?(group.id)
    end
  end
  
  # is the user a direct member of the group?
  def direct_member_of?(group)
    if group.is_a? Array
      group.detect{|g| direct_member_of?(g)}
    elsif group.is_a? Integer
      group_ids.include?(group)
    elsif group.is_a? Group
      group_ids.include?(group.id)
    end
  end
    
  def check_duplicate_memberships(membership)
    raise AssociationError.new('you cannot have duplicate membership') if self.group_ids.include?(membership.group_id)
  end
end

