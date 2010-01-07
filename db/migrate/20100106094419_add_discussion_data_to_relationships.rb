class AddDiscussionDataToRelationships < ActiveRecord::Migration
  def self.up
    Relationship.all.each do |relationship|
      if relationship.discussion.blank?
        mirror_twin = Relationship.find_by_user_id_and_contact_id(relationship.contact_id, relationship.user_id)

        # find or create discussion
        discussion = mirror_twin.try.discussion || relationship.create_discussion

        relationship.update_attribute('discussion_id', discussion.id)
        mirror_twin.update_attribute('discussion_id', discussion.id) if mirror_twin
      end
    end
  end

  def self.down
  end
end
