#  Everything to do with user <> group relationships should be here.
#
#  "memberships" is the join table:
#    user has many groups through memberships
#    group has many users through memberships
#
#  There is only one valid way to establish membership between user and group:
#
#    group.add_user! user
#
#  Other methods should not be used!
#
#  Membership information is cached in the user table. It will get automatically
#  updated whenever membership is created or destroyed. In cases of indirect
#  membership (all_groups) the database is correctly updated but the in-memory
#  object will need to be reloaded if you want the new data.
module UserExtension::Groups
  def self.included(base)
    base.instance_eval do
      has_many :memberships, :foreign_key => 'user_id',
        :dependent => :destroy,
        :before_add => :check_duplicate_memberships

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
        def councils
          self.select{|group|group.council?}
        end
        def recently_active
          find(:all, :limit => 10, :order => 'memberships.visited_at DESC', :conditions => 'groups.type IS NULL')
        end
      end

      # primary groups are:
      # (1) groups user has a direct membership in.
      # (2) committees only if the user is not also the member of the parent group
      # (3) not networks
      # 'primary groups' is useful when you want to list of the user's groups,
      # including committees only when necessary. primary_groups_and_networks is the same
      # but it includes networks in addition to just groups.
      has_many(:primary_groups, :class_name => 'Group', :through => :memberships,
       :source => :group, :conditions => PRIMARY_GROUPS_CONDITION) do

         # most active should return a list of groups that we are most interested in.
         # this includes groups we have recently visited, and groups that we visit the most.
         def most_active
           max_visit_count = find(:first, :select => 'MAX(memberships.total_visits) as id').id || 1
           select = "groups.*, " + quote_sql([MOST_ACTIVE_SELECT, 2.week.ago.to_i, 2.week.seconds.to_i, max_visit_count])
           find(:all, :limit => 13, :select => select, :order => 'last_visit_weight + total_visits_weight DESC')
         end
      end

      has_many(:primary_networks, :class_name => 'Group', :through => :memberships, :source => :group, :conditions => PRIMARY_NETWORKS_CONDITION) do
         # most active should return a list of groups that we are most interested in.
         # this includes groups we have recently visited, and groups that we visit the most.
         def most_active
           max_visit_count = find(:first, :select => 'MAX(memberships.total_visits) as id').id || 1
           select = "groups.*, " + quote_sql([MOST_ACTIVE_SELECT, 2.week.ago.to_i, 2.week.seconds.to_i, max_visit_count])
           find(:all, :limit => 13, :select => select, :order => 'last_visit_weight + total_visits_weight DESC')
         end
      end

      has_many :primary_groups_and_networks, :class_name => 'Group', :through => :memberships, :source => :group, :conditions => PRIMARY_G_AND_N_CONDITION

      # all groups, including groups we have indirect access to even when there
      # is no membership join record. (ie committees and networks)
      has_many :all_groups, :class_name => 'Group',
        :finder_sql => 'SELECT groups.* FROM groups WHERE groups.id IN (#{all_group_id_cache.to_sql}) AND /*SITE_LIMITED*/' do
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

      # DEPRECATED!!
      named_scope :on, lambda { |site|
        if site.network.nil?
          {}
        else
          { :select => "users.*",
            :joins => :memberships,
            :conditions => ["memberships.group_id = ?", site.network.id]
          }
        end
      }

      serialize_as IntArray,
        :direct_group_id_cache, :all_group_id_cache, :admin_for_group_id_cache, :peer_id_cache

      initialized_by :update_membership_cache,
        :direct_group_id_cache, :all_group_id_cache, :admin_for_group_id_cache, :peer_id_cache


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

  # a list of groups that the user is an admin for.
  def admin_for_group_ids
    self.admin_for_group_id_cache
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
    if self.group_ids.include?(membership.group_id)
      raise AssociationError.new(I18n.t(:invite_error_already_member))
    end
  end

  private

  PRIMARY_GROUPS_CONDITION   = '(type IS NULL OR parent_id NOT IN (#{direct_group_id_cache.to_sql}))'
  PRIMARY_NETWORKS_CONDITION = '(type = \'Network\' OR parent_id NOT IN (#{direct_group_id_cache.to_sql}))'
  PRIMARY_G_AND_N_CONDITION  = '(type IS NULL OR type = \'Network\' OR parent_id NOT IN (#{direct_group_id_cache.to_sql}))'
  MOST_ACTIVE_SELECT = '((UNIX_TIMESTAMP(memberships.visited_at) - ?) / ?) AS last_visit_weight, (memberships.total_visits / ?) as total_visits_weight'

end

