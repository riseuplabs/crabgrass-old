=begin

RELATIONSHIP TO GROUPS
    
=end

module PageExtension::Groups

  def self.included(base)
    base.instance_eval do

      has_many :group_participations, :dependent => :destroy
      has_many :groups, :through => :group_participations
      belongs_to :group # the main group
      
      has_many :namespace_groups, :class_name => 'Group', :finder_sql => 'SELECT groups.* FROM groups WHERE groups.id IN (#{namespace_group_ids_sql})'

      # override the ActiveRecord created method
      remove_method :namespace_group_ids
      remove_method :group_ids
    end
  end

  # When getting a list of ids of groups for this page,
  # we use group_participations. This way, we will have
  # current data even if a group is added and the page
  # has not yet been saved.
  # used extensively, and by ferret.
  def group_ids
    group_participations.collect{|gpart|gpart.group_id}
  end
  
  # returns an array of group ids that compose this page's namespace
  # includes direct groups and all the relatives of the direct groups.
  def namespace_group_ids
    Group.namespace_ids(group_ids)
  end
  def namespace_group_ids_sql
    namespace_group_ids.any? ? namespace_group_ids.join(',') : 'NULL'
  end

  # takes an array of group ids, return all the matching group participations
  # this is called a lot, since it is used to determine permission for the page
  def participation_for_groups(group_ids) 
    group_participations.collect do |gpart|
      gpart if group_ids.include? gpart.group_id
    end.compact
  end
  def participation_for_group(group)
    group_participations.detect{|gpart| gpart.group_id == group.id}
  end

  # a list of the group participation objects, but sorted
  # by access (higher number is less access permissions)
  def sorted_group_participations
    group_participations.sort do |a,b|
      (a.access||100) <=> (b.access||100)
    end
  end

  # returns all the groups with a particular access level
  def groups_with_access(access)
    group_participations.collect do |gpart|
      gpart.group if gpart.access == ACCESS[access]
    end.compact
  end

end
