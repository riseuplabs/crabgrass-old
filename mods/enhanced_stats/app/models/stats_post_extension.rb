module StatsPostExtension
 
  def self.add_to_class_definition
    lambda do

      named_scope(:on_pagetype, lambda do |pagetype| {
        :conditions => ['pages.type = ?', pagetype],
        :joins => 'JOIN discussions ON posts.discussion_id=discussions.id JOIN pages ON discussions.page_id=pages.id'
      } end)
    end
  end

end
