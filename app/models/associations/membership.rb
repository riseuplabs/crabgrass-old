#
# user to group relationship
#
#  create_table "memberships", :force => true do |t|
#    t.integer  "group_id",     :limit => 11
#    t.integer  "user_id",      :limit => 11
#    t.datetime "created_at"
#    t.boolean  "admin",                      :default => false
#    t.datetime "visited_at"
#    t.integer  "total_visits", :limit => 11, :default => 0
#    t.string   "join_method"
#  end
#
#  add_index "memberships", ["group_id", "user_id"], :name => "gu"
#  add_index "memberships", ["user_id", "group_id"], :name => "ug"
#

class Membership < ActiveRecord::Base
  attr_accessor :skip_destroy_notification

  belongs_to :user
  belongs_to :group

  named_scope :alphabetized_by_user, lambda { |letter|
    opts = {
      :joins => :user,
      :order => 'users.login ASC',
      :select => 'memberships.*'
    }

    if letter == '#'
      opts[:conditions] = ['users.login REGEXP ?', "^[^a-z]"]
    elsif not letter.blank?
      opts[:conditions] = ['users.login LIKE ?', "#{letter}%"]
    end

    opts
  }

  named_scope :with_users, :include => :user

end

