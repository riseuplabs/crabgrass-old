module StatsPageHistoryExtension

  def self.add_to_class_definition
    lambda do
      acts_as_created_between

      named_scope(:grant_accesses, 
        {:conditions => "page_histories.type LIKE 'Grant%' and user_id != IF(object_type='User',object_id, '')"} )

      named_scope(:page_updates,
        {:select => 'DISTINCT pages.*',
         :conditions => 'page_histories.type = "UpdatedContent"',
         :joins => 'JOIN pages on pages.id = page_histories.page_id' })

      named_scope(:only_pagetype, lambda do |pagetype|
        {:conditions => ['pages.type = ?', pagetype],
         :joins => 'JOIN pages on pages.id = page_histories.page_id'}
      end)

      named_scope(:to_user, {:conditions => ['object_type = "User"']})

      named_scope(:to_group, lambda do |grouptype| 
        conditions = (grouptype == 'Group') ? '(groups.type IS NULL) or (groups.type = "Group")' : "groups.type = '#{grouptype}'"
        {:conditions => conditions, 
         :joins => 'JOIN groups ON groups.id = page_histories.object_id'} 
      end)
    end
  end

end

