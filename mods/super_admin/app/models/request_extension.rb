module RequestExtension

  def self.add_to_class_definition
    lambda do
      named_scope :to_or_created_by_user, lambda { |user|
        # superadmin can approve anything 
        {:conditions => [] }
      }
    end
  end
end

