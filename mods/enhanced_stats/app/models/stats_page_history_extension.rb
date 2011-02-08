module StatsPageHistoryExtension

  def self.add_to_class_definition
    lambda do

      named_scope(:grant_accesses, {:conditions => ['page_histories.type LIKE "Grant%"']} )

      named_scope(:to_user, {:conditions => ['object_type = "User" AND user_id != object_id']})

      named_scope(:to_group, lambda do |grouptype| 
        conditions = (grouptype == 'Group') ? '(groups.type IS NULL) or (groups.type = "Group")' : "groups.type = '#{grouptype}'"
        {:conditions => conditions, 
         :joins => 'JOIN groups ON groups.id = page_histories.object_id'} 
      end)
    end
  end

end

