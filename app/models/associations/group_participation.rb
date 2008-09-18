#
# a GroupParticipation holds the data representing a group's
# relationship with a particular node.
# 
# resolved (boolean) -- the group's involvement with this node has been resolved.  
# view_only (boolean) -- the group's participation is limited to viewing.


class GroupParticipation < ActiveRecord::Base
  belongs_to :page
  belongs_to :group

  def access_sym
    ACCESS_TO_SYM[self.access]
  end

  # can only be used to increase access, not remove it.
  def grant_access=(value)
    value = ACCESS[value.to_sym] if value.is_a?(Symbol) or value.is_a?(String)
    if value
      if read_attribute(:access)
        if read_attribute(:access) > value
          write_attribute(:access, value)
        end
      else
        write_attribute(:access, value)
      end
    end
  end

  # can be used to add or remove access
  def access=(value)
    value = ACCESS[value] if value.is_a? Symbol
    write_attribute(:access, value)
  end

end
