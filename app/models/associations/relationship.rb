# user to user relationship

class Relationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :contact, :class_name => 'User', :foreign_key => :contact_id
  belongs_to :discussion, :dependent => :destroy

  #
  # auto-create discussion when needed.
  #

  def discussion_with_auto_create(*args)
    disc = discussion_without_auto_create(*args)
    return disc if disc

    mirror_twin = Relationship.find_by_user_id_and_contact_id(contact_id, user_id)
    if mirror_twin and (disc = mirror_twin.discussion_without_auto_create)
      self.discussion_id = disc.id
    else
      disc = self.create_discussion
      if mirror_twin
        mirror_twin.discussion = disc
        mirror_twin.save if !mirror_twin.new_record?
      end
    end
    self.save unless self.new_record?
    return disc
  end

  alias_method_chain :discussion, :auto_create

end
