#
# the notice column holds a serialized hash with information regarding
# notify event: if a user has 'sent' you a page and included a message, 
# this information is stored in 'notice'.
# 
# it shown once and then deleted when you view the page.
#

class AddNoticeToUserParticipations < ActiveRecord::Migration
  def self.up
    add_column :user_participations, :notice, :text
  end

  def self.down
    remove_column :user_participations, :notice
  end
end

