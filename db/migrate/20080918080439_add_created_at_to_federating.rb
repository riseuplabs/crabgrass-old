class AddCreatedAtToFederating < ActiveRecord::Migration
  def self.up
    add_column "federatings", "created_at", :datetime
  end

  def self.down
    remove_column "federatings", "created_at"
  end
end
