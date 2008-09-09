#
# a UserParticipation holds the data representing a user's
# relationship with a particular page.
# 
# fields:
# access, :integer      -- enum which determines page access. see environment.rb
# viewed_at, :datetime  -- last visit
# changed_at, :datetime -- last modification by user
# watch, :boolean       -- is the user watching page for changes?
# star, :boolean        -- has the user starred this page?
# resolved, :boolean    -- the user's involvement with this node has been resolved.
# viewed, :boolean      -- the user has seen the lastest version
# attend, :boolean      -- the user will attend event
# notice, :text         -- serialized data sent with a notify command
#

class UserParticipation < ActiveRecord::Base
  belongs_to :page
  belongs_to :user
  serialize :notice

  def access_sym
    ACCESS_TO_SYM[self.access]
  end

  # can only be used to increase access, not remove it.
  def grant_access=(value)
    value = ACCESS[value.to_sym] if value.is_a?(Symbol) or value.is_a?(String)
    if value
      if read_attribute(:access)
        write_attribute(:access, [value,read_attribute(:access)].min )
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

