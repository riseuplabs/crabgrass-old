class ChannelsUser < ActiveRecord::Base
  tz_time_attributes :last_seen
  belongs_to :channel
  belongs_to :user
end
