# levels of page access
ACCESS = {:admin => 1, :edit => 2, :view => 3}.freeze
ACCESS_TO_SYM = {1 => :admin, 2 => :edit, 3 => :view}.freeze
ACCESS_ADMIN = 1
ACCESS_EDIT = 2
ACCESS_VIEW = 3

# types of page flows
FLOW = {:deleted => 3}.freeze

