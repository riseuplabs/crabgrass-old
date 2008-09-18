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

   # only this method should be used for adding groups to a network
   def add_group!(group, delegation=nil)
     self.federatings.create!(:group => group, :delegation => delegation, :council => council)
     group.org_structure_changed
     group.save!
   end
   
   # only this method should be used for removing groups from a network
   def remove_group!(group)
     self.federatings.detect{|f|f.group_id == group.id}.destroy
     group.org_structure_changed
     group.save!
   end

end

