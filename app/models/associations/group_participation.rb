=begin
a GroupParticipation holds the data representing a group's
relationship with a particular page.

create_table "group_participations", :force => true do |t|
  t.integer  "group_id",          :limit => 11
  t.integer  "page_id",           :limit => 11
  t.integer  "access",            :limit => 11
  t.boolean  "static",                          :default => false
  t.datetime "static_expires"
  t.boolean  "static_expired",                  :default => false
  t.integer  "featured_position", :limit => 11
end

add_index "group_participations", ["group_id", "page_id"], :name => "index_group_participations"
=end

class GroupParticipation < ActiveRecord::Base
  # this includes the ability to find featured-pages in GroupParticipation
  include GroupParticipationExtension::Featured
  include GroupParticipationExtension::PageHistory

  belongs_to :page
  belongs_to :group

  def entity
    group
  end

  def access_sym
    ACCESS_TO_SYM[self.access]
  end

  # can only be used to increase access, not remove it.
  def grant_access=(value)
    value = ACCESS[value.to_sym] if value.is_a?(Symbol) or value.is_a?(String)
    if value
      if read_attribute(:access)
        if read_attribute(:access) > value
          write_attribute(:access, value)
        end
      else
        write_attribute(:access, value)
      end
    end
  end

  # can be used to add or remove access
  def access=(value)
    value = ACCESS[value] if value.is_a? Symbol or value.is_a?(String)
    write_attribute(:access, value)
  end

end
