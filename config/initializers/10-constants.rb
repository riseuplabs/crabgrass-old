# levels of page access
# why is setting a default a good idea?
#ACCESS = (Hash.new(3).merge({:admin => 1, :edit => 2, :view => 3})).freeze
#ACCESS_TO_SYM = (Hash.new(:view).merge({1 => :admin, 2 => :edit, 3 => :view})).freeze

ACCESS = HashWithIndifferentAccess.new({:admin => 1, :edit => 2, :view => 3, :none => nil}).freeze
ACCESS_TO_SYM = {1 => :admin, 2 => :edit, 3 => :view}.freeze

ACCESS_ADMIN = 1
ACCESS_EDIT = 2
ACCESS_VIEW = 3

# types of page flows
FLOW = {:deleted => 3, :announcement => 5}.freeze

# enum of media types
MEDIA_TYPE = {
  :image => 1,
  :audio => 2,
  :video => 3,
  :document => 4
}.freeze

# enum of actions for tracking
ACTION = {
  :view => 1,
  :edit => 2,
  :star => 3,
  :unstar => 4,
  :comment => 5, # not used yet
  :share => 6 # not used yet
}.freeze

ARROW = " &raquo; "
BULLET = " &bull; "
RARROW = " &raquo; "
LARROW = " &laquo; "

# group and user names which cannot be used
FORBIDDEN_NAMES = %w(account admin assets avatars chat calendar calendars contact custom_appearances embed event events feeds files translator group groups images invites issues javascripts latex me membership messages network networks page pages people person posts profile places plugin_assets requests static stats stylesheets visualize wiki code codes).freeze

# a time to use when displaying recent records
RECENT_SINCE_TIME = 2.weeks.ago.freeze
