module StatsPageHistoryExtension

  def self.add_to_class_definition
    lambda do

      named_scope(:created_between, lambda do |from, to|
        to += ' 23:59:59'
        {:conditions => {:created_at => from..to} } 
      end)

      named_scope(:grant_accesses, 
        {:conditions => "page_histories.type LIKE 'Grant%' and user_id != IF(object_type='User',object_id, '')"} )

      named_scope(:to_user, {:conditions => ['object_type = "User"']})

      named_scope(:to_group, lambda do |grouptype| 
        conditions = (grouptype == 'Group') ? '(groups.type IS NULL) or (groups.type = "Group")' : "groups.type = '#{grouptype}'"
        {:conditions => conditions, 
         :joins => 'JOIN groups ON groups.id = page_histories.object_id'} 
      end)
    end
  end

end

