require 'lib/participation'

UserParticipation.instance_eval do 
  include FeedR::Participation
end

class UserParticipation < ActiveRecord::Base
end
