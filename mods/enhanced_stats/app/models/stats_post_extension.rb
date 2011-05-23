module StatsPostExtension
 
  def self.add_to_class_definition
    lambda do
      acts_as_created_between
   
      named_scope(:on_pages, 
        {:conditions => 'discussions.page_id IS NOT NULL',
         :joins => 'JOIN discussions ON posts.discussion_id=discussions.id'})

      named_scope(:on_pagetype, lambda do |pagetype| {
        :conditions => ['pages.type = ?', pagetype],
        :joins => 'JOIN discussions ON posts.discussion_id=discussions.id JOIN pages ON discussions.page_id=pages.id'
      } end)
    end
  end

end
