require 'thinking_sphinx/active_record'
require 'thinking_sphinx/association'
require 'thinking_sphinx/configuration'
require 'thinking_sphinx/field'
require 'thinking_sphinx/index'

# = ThinkingSphinx
# 
# This plugin was inspired by Cloudburst's Ultrasphinx plugin and the included
# Sphinx Client - neither quite scratched my itch, though. The main feature I
# was after is the ability to include multiple fields from associations which
# may be several levels deep.
#
# For example:
#
#   class Invoice < ActiveRecord::Base
#     belongs_to :customer
#     # ...
#     define_index do |index|
#       index.includes.customer.first_name
#       index.includes.customer.last_name
#     end
#     # ...
#   end
#
# It is also quite easy to concatenate a few fields together. So, to change
# the above example:
#
#   define_index do |index|
#     index.includes.customer(:first_name, :last_name).as.customer_name
#   end
#
# The goal for this plugin is to push convention over configuration - there
# are no settings for the location of logs, pid files or index files. These
# are located in the log folder for logs and the pid file, and within
# db/sphinx/ for the index data files. Sphinx config files are generated
# and indexed in one task - so there is actually no opportunity to edit the
# conf file manually. While you may find this annoying, it provides me with
# some incentive to make sure the generation does everything that's required.
#
# So, once you've defined your indexes, you need to index the data, then start
# the daemon. Both are done with rake tasks:
#
#   rake thinking_sphinx:index
#   rake thinking_sphinx:start
#
# There's also tasks 'stop' and 'restart' in the same namespace - their names
# should give you some indication for what they do. You can call the index
# task while the daemon is running - it will rotate the logs automatically.
#
# All these tasks can also be called in the abbreviated namespace, ts:
#
#   rake ts:start
#   rake ts:index (or even ts:in)
#   rake ts:restart
#
# As for searching, again quite simple:
#
#   Invoice.search :conditions => {:customer_name => "Pat"}
#   Invoice.search "Pat"
#
# For pagination, just pass in the :page parameter:
#
#   Invoice.search "Pat", :page => (params[:page] || 1)
#
# The results returned by that call can be used by the will_paginate view
# helper from the plugin of the same name (if installed).
#
# On the list of upcoming features is the ability for custom sorting and
# grouping.
#
module ThinkingSphinx
  def self.indexed_models
    @@indexed_models ||= []
  end
  
  def self.indexed_models=(value)
    @@indexed_models = value
  end
end