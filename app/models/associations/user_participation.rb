#
# a UserParticipation holds the data representing a user's
# relationship with a particular page.
#
# fields:
# access, :integer      -- enum which determines page access. see 00-constants.rb
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

  # use this for counting stars :)
  include UserParticipationExtension::Starring
  include UserParticipationExtension::PageHistory

  # maybe later use this to replace all the notification stuff
  #  include ParticipationExtension::Subscribe

  def entity
    user
  end

  def access_sym
    ACCESS_TO_SYM[self.access]
  end

  # can only be used to increase access.
  # because access is only increased, you cannot remove access with grant_access.
  def grant_access=(value)
    value = ACCESS[value] if value.is_a?(Symbol) or value.is_a?(String)
    if value
      if read_attribute(:access)
        write_attribute(:access, [value,read_attribute(:access)].min )
      else
        write_attribute(:access, value)
      end
    end
  end

  # sets the access level to be value, regardless of what it was before.
  # if value is nil, no change is made. If value is :none, then access is removed.
  def access=(value)
    return if value.nil?
    value = ACCESS[value] if value.is_a? Symbol or value.is_a?(String)
    write_attribute(:access, value)
  end
end

