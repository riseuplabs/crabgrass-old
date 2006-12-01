# A Federation holds the data relating to an association between a group and a network.
# council (group)     -- the subgroup of the network that all the delegates are part of.
# delegates (group)   -- the subgroup of the group that the delegates come from.

class Federation < ActiveRecord::Base
  belongs_to :group
  belongs_to :network
end
