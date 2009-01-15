#!/usr/bin/ruby

# Ejabberd external authentication script using Crabgrass users table
# Written by Pietro Ferrari <pietro@riseup.net>
# Based on:
# http://svn.process-one.net/ejabberd/trunk/doc/dev.html#htoc9
# http://thinkincode.net/2007/1/1/ruby-y-ejabberd
# http://www.ouvre-boite.com/2008/10/24/authenticating-ejabberd-against-a-ruby-on-rails-database/

require 'rubygems'
require 'active_record'

RAILS_ROOT = "#{File.dirname(__FILE__)}/../../.."

# Trimmed down version of the user class
require "#{File.dirname(__FILE__)}/user"

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

def auth(username, password)
  User.authenticate(username, password.chomp) ? 1 : 0
end

def isuser(username)
  User.find_by_login(username) ? 1 : 0
end

buffer = String.new
while STDIN.sysread(2, buffer) && buffer.length == 2
  length = buffer.unpack('n')[0]
  operation, username, domain, password = STDIN.sysread(length).split(':')
  response = case operation
             when 'auth'
               auth(username, password)
             when 'isuser'
               isuser(username)
             else
               0
             end
  STDOUT.syswrite([2, response].pack('nn'))
end
