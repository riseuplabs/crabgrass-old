#!/usr/bin/ruby

# Ejabberd external authentication script using Crabgrass users table
# Written by Pietro Ferrari <pietro@riseup.net>
# Based on:
# http://svn.process-one.net/ejabberd/trunk/doc/dev.html#htoc9
# http://thinkincode.net/2007/1/1/ruby-y-ejabberd
# http://www.ouvre-boite.com/2008/10/24/authenticating-ejabberd-against-a-ruby-on-rails-database/

require 'rubygems'
require 'erlectricity'

begin
  # try the rubygems
  require 'active_record'
rescue Exception
  # try the package
  $: << "/usr/share/rails/activerecord/lib"
  require 'active_record'
end

RAILS_ROOT = "/home/pietro/repos/crabgrass"

require "#{RAILS_ROOT}/lib/int_array"

# Trimmed down version of the user class
require "#{File.dirname(__FILE__)}/user"

require "#{File.dirname(__FILE__)}/group"

# Default to the production environment.
environment = 'development'

# Database config file
db_config_file = "#{RAILS_ROOT}/config/database.yml"
db_config = YAML.load_file(db_config_file)[environment]

ActiveRecord::Base.establish_connection(
   :adapter  => db_config['adapter'],
   :host     => db_config['host'],
   :username => db_config['username'],
   :password => db_config['password'],
   :database => db_config['database'])

def can_chat?(username, groupname)
  user = User.find_by_login username
  group = Group.find_by_name groupname
  user.member_of?(group) ? "yes" : "no"
end

receive do |f|
  f.when([:array, Array]) do |arr|
    result = can_chat?(arr[0], arr[1])
    f.send!([:result, "You said: #{result}"])
    f.receive_loop
  end
end

