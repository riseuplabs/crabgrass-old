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

  def self.page_tags_for_group(group)
    Tag.find_by_sql(%Q[
      SELECT tags.*, count(name) as count
      FROM tags
      INNER JOIN taggings ON tags.id = taggings.tag_id AND taggings.taggable_type = 'Page'
      INNER JOIN group_participations ON group_participations.page_id = taggings.taggable_id
      AND group_participations.group_id IN (#{group.group_and_committee_ids.join(', ')})
      GROUP BY name
      ORDER BY name
    ])
  end

end

