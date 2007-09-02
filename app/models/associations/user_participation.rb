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
end

