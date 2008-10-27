=begin

Caching IDs
 
The idea here is that every user in a social networking universe
has a lot of relationships to other entities that might be expensive
to discover. For example, a list of all your peers or a list of all
groups you have direct or indirect access to. So, we cache it, in
the form of serialized arrays of integers corresponding to the ids of the
foreign relationships.

If you are paying attention, you will realize this is stupid. A couple reasons
why it is not:

  (1) by using compressed integers for serialization, we can actually store
      a lot of ids without taking up too much space.
  (2) it is much faster to deserialize a big array of integers than it is
      to join in another table or make an extra query.

In many cases, all we *want* are the ids, since this is sufficient
to test membership and to display name and avatar (if ever get around
to creating a memcached for users and groups that stores [id,name,avatar_id]).

Also, we make a lot of queries of the form "group_id IN (1,2,3,4)".
This is fast, according to the mysql manual:

   If all values are constants, they are evaluated according to
   the type of expr and sorted. The search for the item then is
   done using a binary search. This means IN is very quick if
   the IN value list consists entirely of constants.

This suggests that if we stored the ids caches pre-sorted, it would be
slightly faster.

As a handy bit of fun, if any of these ids caches changes, we increment
the user's version. This can be then used to easily expire caches which
use these values.

Columns
--------

  version -- increments when any of the id caches are changed
 
  id caches -- there are many columns to cache our relationships,
    because they are used very frequently and take time to calculate.
    The names of the cache attributes end with "_cache". 

=end

module UserExtension
  module Cache
    def self.included(base)
      base.extend ClassMethods
    end

    # Be careful with this method: it is called any time a Membership
    # object is created or destroyed, and it is also called any time
    # read_attribute(*_group_id_cache) is nil. Therefore, we better
    # set the id caches to non-nil in this method unless we want to
    # recurse forever.
    def update_membership_cache(membership=nil)
      clear_access_cache
      direct, all = get_group_ids
      peer = get_peer_ids(direct)
      update_attributes :version => version+1,
        :direct_group_id_cache => direct,
        :all_group_id_cache    => all,
        :peer_id_cache         => peer
    end

    #
    # When our membership changes, we need to clear the peer cache of all
    # the users who might have their peer info change. To do so, this method
    # must be called in two places:
    #   1) after a new membership is created
    #   2) before a membership is destroyed
    #
    def clear_peer_cache_of_my_peers(membership=nil)
      if peer_id_cache.any?
        self.class.connection.execute(%Q[
          UPDATE users SET peer_id_cache = NULL
          WHERE id IN (#{peer_id_cache.join(',')})
        ])
      end
    end

    def increment_group_version(membership)
      membership.group.increment!(:version)
    end

    # This should be called if a change in relationships has potentially
    # invalidated the cache. For example, adding or removing a commmittee.
    # This only updates the database: if you want to update the in-memory
    # object, follow this call with reload()
    def clear_cache
       self.class.connection.execute(%Q[
         UPDATE users SET 
         tag_id_cache = NULL, direct_group_id_cache = NULL, foe_id_cache = NULL,
         peer_id_cache = NULL, friend_id_cache = NULL, all_group_id_cache = NULL
         WHERE id = #{self.id}
       ])
    end
    
    def update_contacts_cache()
      friend,foe = get_contact_ids
      update_attributes :version => version+1,
        :friend_id_cache => friend,
        :foe_id_cache    => foe
    end
      
    # include direct memberships, committees, and networks
    def get_group_ids
      if self.id
        direct = Group.connection.select_values(%Q[
          SELECT groups.id FROM groups
          INNER JOIN memberships ON groups.id = memberships.group_id
          WHERE (memberships.user_id = #{self.id})
        ])
      else
        direct = []
      end
      if direct.any?
        committee = Group.connection.select_values(%Q[
          SELECT groups.id FROM groups
          WHERE groups.parent_id IN (#{direct.join(',')})
          AND groups.is_council = 0
        ])
        network = Group.connection.select_values(%Q[
          SELECT groups.id FROM groups
          INNER JOIN federatings ON groups.id = federatings.network_id
          WHERE federatings.group_id IN (#{direct.join(',')})
        ])
        if network.any?
          # look for networks that our direct networks might be a member of
          network += Group.connection.select_values(%Q[
            SELECT groups.id FROM groups
            INNER JOIN federatings ON groups.id = federatings.network_id
            WHERE federatings.group_id IN (#{network.join(',')})
          ])
          committee += Group.connection.select_values(%Q[
            SELECT groups.id FROM groups
            WHERE groups.parent_id IN (#{network.join(',')})
            AND groups.is_council = 0
          ])
        end
      else
        committee, network = [],[]
      end
      direct = direct.collect{|id| id.to_i}.uniq
      all = (direct + committee + network).collect{|id|id.to_i}.uniq
      [direct, all]
    end

    def get_peer_ids(group_ids)
      return [] unless self.id
      User.connection.select_values( %Q[
        SELECT DISTINCT users.id FROM users
        INNER JOIN memberships ON users.id = memberships.user_id
        WHERE users.id != #{id}
        AND memberships.group_id IN (#{ group_ids.any? ? group_ids.join(',') : 'NULL'})
      ])
    end

    def get_contact_ids()
      return [[],[]] unless self.id
      foe = [] # no foes yet.
      friend = Contact.connection.select_values( %Q[
        SELECT contacts.contact_id FROM contacts
        WHERE type = 'Friend' AND contacts.user_id = #{self.id}
      ])
      [friend,foe]
    end
    
    def update_tag_cache
      # this query sucks and should be optimized
      # see http://dev.mysql.com/doc/refman/5.0/en/in-subquery-optimization.html
      # TODO: acts_as_taggable_on includes the user_id in every tagging,
      # thus making it easy to find all the tags you have made. maybe this is
      # what we should return here instead?
      if self.id
        ids = Tag.connection.select_values(%Q[
          SELECT tags.id FROM tags
          INNER JOIN taggings ON tags.id = taggings.tag_id
          WHERE taggings.taggable_type = 'Page' AND taggings.taggable_id IN
           (SELECT pages.id FROM pages
            INNER JOIN user_participations ON pages.id = user_participations.page_id
            WHERE user_participations.user_id = #{id})
        ])
      else
        ids = []
      end
      update_attributes :version => version+1, :tag_id_cache => ids
    end

    module ClassMethods

      # takes an array of user ids and NULLs out the membership cache
      # of those users. however, the peer cache is not NULLed.
      def clear_membership_cache(ids)
        return unless ids.any?
        self.connection.execute(%Q[
          UPDATE users SET 
          direct_group_id_cache = NULL, all_group_id_cache = NULL
          WHERE id IN (#{ ids.join(',') })
        ])
      end

      ## serialize_as
      ## ---------------------------------
      ##
      ## usage:
      ##
      ## class Tree < ActiveRecord::Base
      ##   serialize_as IntArray, :branches, :roots
      ## end
      ##
      ## In this case, the column 'branches' will be serialized and unserialized
      ## using the IntArray.to_s and IntArray.new methods (respectively).
      ##
      ## It would be cool if I made this into a plugin, but then again, a lot
      ## of things would be cool.
      ##
      def serialize_as(klass, *keywords)
        for word in keywords
          word = word.id2name
          module_eval <<-"end_eval"
            def #{word}=(value)
              @#{word} = #{klass.to_s}.new(value)
              write_attribute('#{word}', @#{word}.to_s)
            end
            def #{word}
              @#{word} ||= #{klass.to_s}.new( read_attribute('#{word}') )
            end
          end_eval
        end
      end
      
      ## initialized_by
      ## ---------------------------------
      ##
      ## usage:
      ##
      ## class Tree < ActiveRecord::Base
      ##   initialized_by :my_method, :my_attribute
      ## end
      ##
      ## In this case, my_method() will be called each time my_attribute()
      ## is accessed if my_attribute is nil.
      ##
      def initialized_by(method, *attributes)
        method = method.id2name
        for attribute in attributes
          attribute = attribute.id2name
          module_eval <<-"end_eval"
            alias_method :#{attribute}_without_initialize, :#{attribute}
            def #{attribute}
              self.#{method}() if read_attribute('#{attribute}').nil?
              #{attribute}_without_initialize()
            end
          end_eval
        end
      end
    end # end ClassMethods

  end
end
