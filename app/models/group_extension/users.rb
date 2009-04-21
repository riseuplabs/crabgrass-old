#
# Module that extends Group behavior.
#
# Handles all the group <> user relationships
#
module GroupExtension::Users

  def self.included(base)
    base.instance_eval do
      has_many :memberships, :dependent => :destroy,
        :before_add => :check_duplicate_memberships

      has_many :users, :through => :memberships do
        def <<(*dummy)
          raise Exception.new("don't call << on group.users");
        end
        def delete(*records)
          raise Exception.new("don't call delete on group.users");
        end
      end
    end     
  end

  def user_ids
    @user_ids ||= memberships.collect{|m|m.user_id}
  end

  def all_users
    users
  end

  # association callback
  def check_duplicate_memberships(membership)
    membership.user.check_duplicate_memberships(membership)
  end

  def relationship_to(user)
    relationships_to(user).first
  end
  def relationships_to(user)
    return [:stranger] unless user
    return [:stranger] if user.is_a? UnauthenticatedUser
    (@relationships ||= {})[user.login] ||= get_relationships_to(user)
  end
  def get_relationships_to(user)
    ret = []
#   ret << :admin    if ...
    ret << :member   if user.member_of?(self)
#   ret << :peer     if ...
    ret << :stranger if ret.empty?
    ret
  end
  
  # this is the ONLY way to add users to a group.
  # all other methods will not work.
  def add_user!(user)
    self.memberships.create! :user => user
    user.update_membership_cache
    user.clear_peer_cache_of_my_peers

    @user_ids = nil
    self.increment!(:version)
  end
  
  # this is the ONLY way to remove users from a group.
  # all other methods will not work.
  def remove_user!(user)
    membership = self.memberships.find_by_user_id(user.id)
    raise ErrorMessage.new('no such membership') unless membership

    user.clear_peer_cache_of_my_peers
    membership.destroy
    user.update_membership_cache

    @user_ids = nil
    self.increment!(:version)
  end
  
# maps a user <-> group relationship to user <-> language
#  def in_user_terms(relationship)
#    case relationship
#      when :member;   'friend'
#      when :ally;     'peer'
#      else; relationship.to_s
#    end  
#  end

end

