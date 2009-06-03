#
# user to group relationship
#
# created_at (datetime) -- 
#

class Membership < ActiveRecord::Base
  attr_accessor :skip_destroy_notification

  belongs_to :user
  belongs_to :group
  belongs_to :page

  named_scope :alphabetized_by_user, lambda { |letter|
    opts = {
      :joins => :user,
      :order => 'users.login ASC'
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

