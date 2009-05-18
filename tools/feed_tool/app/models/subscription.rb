class Subscription < ActiveRecord::Base
  
  
  # We need two associations here, to make subscriptions possible on group- AND user-level
  # TODO find out, how they affect each other, if both exist
  has_one :group_participation
  has_one :user_participation

  has_one :user, :through => :user_participation
  has_one :group, :through => :group_participation
  
  #
  # The associations
  #
  
  # returns the union of the two possible subscribables
  def unique_subscribables
    return group_participation.subscribable | user_participations.subscribable
  end
  
  # returns the subscribable through a group_participation
  def group_subscribable
    return group_participation.subscribable
  end
  
  # returns the subscribable through a user_participation
  def user_subscribable
    return user_participation.subscribable
  end

  
end

