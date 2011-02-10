module StatsPageExtension
 
  def self.add_to_class_definition
    lambda do

      named_scope(:created_between, lambda do |from, to|
        to += ' 23:59:59'
        {:conditions => {:created_at => from..to} } 
      end)

      named_scope(:on_pagetype, lambda do |pagetype| {
        :conditions => ['pages.type = ?', pagetype],
        :joins => 'JOIN discussions ON posts.discussion_id=discussions.id JOIN pages ON discussions.page_id=pages.id'
      } end)
    end
  end

end
