# These are the trackings per hour
# They are filled from trackings table every hour.
# dailies fetch their data from here every day.
#
class Hourly < ActiveRecord::Base
  belongs_to :page
end
