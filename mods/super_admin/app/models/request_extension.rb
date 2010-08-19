module RequestExtension

  def self.add_to_class_definition
    lambda do
      named_scope :to_or_created_by_user, lambda { |user|
        if user.superadmin?
          # superadmin can approve anything 
          {:conditions => [] }
        else 
          {:conditions => [
          "(recipient_id = ? AND recipient_type = 'User') OR (recipient_id IN (?) AND recipient_type = 'Group') OR (created_by_id = ?)",
          user.id, user.admin_for_group_ids, user.id]}
        end
      }
    end
  end
end

