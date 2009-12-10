#
# This migration does three things:
#
# (1) removes stupid indexes -- there are a lot of indexes that i am pretty sure
#     serve no purpose except to slow down the database. (created_by_id and
#     updated_by_id are used, but only very rarely.)
#
# (2) removes duplicates on the user_participations table.
#
# (3) ensures that there will be no more duplicates on the user_participations
#     table by adding a unique index.
#
class RemoveRidiculousIndexes < ActiveRecord::Migration
  def self.up
    remove_index "pages", :name => "index_pages_on_resolved"
    remove_index "pages", :name => "index_pages_on_public"
    remove_index "pages", :name => "index_page_created_by_id"
    remove_index "pages", :name => "index_page_updated_by_id"

    # these are going away
    remove_index "user_participations", :name => "index_user_participations_page"
    remove_index "user_participations", :name => "index_user_participations_user"
    remove_index "user_participations", :name => "index_user_participations_viewed"
    remove_index "user_participations", :name => "index_user_participations_watch"
    remove_index "user_participations", :name => "index_user_participations_star"
    remove_index "user_participations", :name => "index_user_participations_resolved"
    remove_index "user_participations", :name => "index_user_participations_attend"

    # this one will get added back later as unique
    remove_index "user_participations", :name => "index_user_participations_page_user"

    # remove duplicate user_participation entries and make sure they don't come back.
    conn = UserParticipation.connection
    conn.execute "CREATE TABLE keepers AS SELECT * FROM user_participations GROUP BY page_id, user_id"
    conn.execute "DELETE FROM user_participations"
    conn.execute "INSERT INTO user_participations SELECT * FROM keepers"
    conn.execute "DROP TABLE keepers"

    add_index "user_participations", [:page_id, :user_id], :unique => true, :name => 'page_and_user'
  end

  def self.down
    add_index "pages", ["resolved"], :name => "index_pages_on_resolved"
    add_index "pages", ["public"], :name => "index_pages_on_public"
    add_index "pages", ["created_by_id"], :name => "index_page_created_by_id"
    add_index "pages", ["updated_by_id"], :name => "index_page_updated_by_id"

    add_index "user_participations", ["page_id"], :name => "index_user_participations_page"
    add_index "user_participations", ["user_id"], :name => "index_user_participations_user"
    add_index "user_participations", ["viewed"], :name => "index_user_participations_viewed"
    add_index "user_participations", ["watch"], :name => "index_user_participations_watch"
    add_index "user_participations", ["star"], :name => "index_user_participations_star"
    add_index "user_participations", ["resolved"], :name => "index_user_participations_resolved"
    add_index "user_participations", ["attend"], :name => "index_user_participations_attend"

    add_index "user_participations", ["page_id", "user_id"], :name => "index_user_participations_page_user"
    remove_index "user_participations", :name => "page_and_user"
  end
end

