#
# defines a simple method 'info()' for printing debugging messages
#
# sometimes, it is much more useful to use print for debugging than
# to step through with a debugger.
#
# to enable the printing of the 'info()' messages, define the INFO
# environment variable:
#
#  INFO=1 ruby test/unit/user_test.rb
#
#  INFO=0 rake test:units
#
#  INFO=3 script/server
#
# The info level determines how much is shown:
#
# 0 -- only high level stuff
# 1 -- more detail
# 2 -- even more detail
# and so on...
#

def info(str,level=0)
  if ENV['INFO'] and ENV['INFO'].to_i >= level
    puts ('  '*level) + str.to_s
    STDOUT.flush
  end
end

