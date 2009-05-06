##
## This extends the tags class in acts_as_taggable_on
##
## This files is included by config/initializers/libraries.rb
## which is loaded after the plugin is loaded and before
## the application.
##

class Tag < ActiveRecord::Base 
  # takes a taggable class and set of taggable ids
  # and returns tags that are on these taggables
  named_scope :for_taggables, lambda {|klass, ids|
    { :select => 'tags.*, count(name) as count', 
      :joins => "INNER JOIN taggings ON tags.id = taggings.tag_id AND taggings.taggable_type = '#{klass}'",
      :conditions => ["taggings.taggable_id IN (?)",ids],
      :group => 'name', 
      :order => 'name' }
  }


end

