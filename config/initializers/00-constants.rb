# levels of page access
ACCESS = {:admin => 1, :edit => 2, :view => 3}.freeze
ACCESS_TO_SYM = {1 => :admin, 2 => :edit, 3 => :view}.freeze
ACCESS_ADMIN = 1
ACCESS_EDIT = 2
ACCESS_VIEW = 3

# types of page flows
FLOW = {:deleted => 3, :gallery => 4, :announcement => 5}.freeze

# enum of media types
MEDIA_TYPE = {
  :image => 1, 
  :audio => 2,
  :video => 3,
  :document => 4
}.freeze

ARROW = " &raquo; "
BULLET = " &bull; "

# This is the time in years a password should hold for a brute force attack at
# minimum, assuming 1000 attempts per second.
unless defined? MIN_PASSWORD_STRENGTH
 MIN_PASSWORD_STRENGTH = 2
end

begin
  LANGUAGES = Language.find(:all).freeze
rescue Exception
  # the database doesn't exist yet.
  LANGUAGES = []
end

