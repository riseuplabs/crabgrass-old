class RequestDiscussionPage < Page; end
class RequestPage < Page; end

class CreateNewRequestSystem < ActiveRecord::Migration

  def self.up
    # fix memberships table:
    remove_index  :memberships, :name => :index_memberships
    remove_column :memberships, :page_id
    add_column    :memberships, :admin, :boolean, :default => false
    add_index     :memberships, [:group_id, :user_id], :name => :gu
    add_index     :memberships, [:user_id, :group_id], :name => :ug

    # run 'rake ts:index' after this is done
    ThinkingSphinx.updates_enabled = false
   
    # destroy page-based request system
    RequestPage.destroy_all
    RequestDiscussionPage.destroy_all

    # create requests
    create_table "requests", :force => true do |t|
      t.integer  "created_by_id"
      t.integer  "approved_by_id"

      t.integer  "recipient_id"
      t.string   "recipient_type", :limit => 5

      t.string   "email"
      t.string   "code", :limit => 8

      t.integer  "requestable_id"
      t.string   "requestable_type", :limit => 10

      t.integer  "shared_discussion_id"
      t.integer  "private_discussion_id"

      t.string   "state", :limit => 10
      t.string   "type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    # note: the name suffixes with digits are specifying the key length to schema.rb
    execute "CREATE INDEX created_by_0_2    ON requests (created_by_id,state(2))"
    execute "CREATE INDEX recipient_0_2_2   ON requests (recipient_id,recipient_type(2),state(2))"
    execute "CREATE INDEX requestable_0_2_2 ON requests (requestable_id,requestable_type(2),state(2))"

    add_index :requests, :code, :name => :code
    add_index :requests, :created_at, :name => :created_at
    add_index :requests, :updated_at, :name => :updated_at
  end

  def self.down
    # restore memberships table:
    add_column    :memberships, :page_id, :integer
    add_index     :memberships, ["group_id", "user_id", "page_id"], :name => "index_memberships"
    remove_column :memberships, :admin
    remove_index  :memberships, :name => :gu
    remove_index  :memberships, :name => :ug

    # can't undo destruction of page-based requests

    # destroy requests
    drop_table :requests
  end

end
