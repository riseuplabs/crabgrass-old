class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.column "comment", :string
      t.column "name", :string
      t.column "content_type", :string
      t.column "data", :binary
      t.column "created_by_id", :integer
      t.column "created_at", :timestamp
      t.column "thumb", :binary
      t.column "type", :string
    end
  end

  def self.down
    drop_table :pictures
  end
end
