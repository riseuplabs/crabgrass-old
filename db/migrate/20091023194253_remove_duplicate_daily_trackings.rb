class RemoveDuplicateDailyTrackings < ActiveRecord::Migration
  def self.up
    # this is a consistency migration.
    # It makes sure we do not have duplicate entrys for the view, stars and
    # edit trackings.
    dup_ids=Daily.find(:all, :joins => "INNER JOIN dailies AS d2 ON dailies.page_id = d2.page_id AND dailies.created_at = d2.created_at AND dailies.id < d2.id").map(&:id)
    Daily.delete(dup_ids)
  end

  def self.down
    # nothing to be done here.
  end
end
