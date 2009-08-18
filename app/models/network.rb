#
# Network
#
# A network is an aggregation of groups.
#
# Networks are like groups, except:
#
# * Networks may have both users and other groups as members
#   (the join table for groups is 'federations')
#
# * Being a member of a network does not make you the peer of the other
#   members of the network.
#
# * Networks show up under the networks tab instead of the groups tab.
#
class Network < Group

  has_many :federatings, :dependent => :destroy
  has_many :groups, :through => :federatings
  has_many :sites

  # only this method should be used for adding groups to a network
  def add_group!(group, delegation=nil)
    self.federatings.create!(:group => group, :delegation => delegation, :council => council)
    group.org_structure_changed
    group.save!
    Group.increment_counter(:version, self.id) # in case self is not saved
    self.version += 1 # in case self is later saved
  end

  # only this method should be used for removing groups from a network
  def remove_group!(group)
    self.federatings.detect{|f|f.group_id == group.id}.destroy
    group.org_structure_changed
    group.save!
    Group.increment_counter(:version, self.id) # in case self is not saved
    self.version += 1 # in case self is later saved
  end

  # Whenever the organizational structure of this network has changed
  # this function should be called. Afterward, a save is required.
  def org_structure_changed(child=nil)
    User.clear_membership_cache(user_ids)
    self.version += 1
    self.groups.each do |group|
      group.org_structure_changed(child)
      group.save!
    end
  end

  def all_users
    groups.collect{|group| group.all_users}.flatten.uniq
  end
end

