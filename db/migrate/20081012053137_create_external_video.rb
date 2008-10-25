class CreateExternalVideo < ActiveRecord::Migration
  def self.up
    create_table :external_videos do |t|
      t.string  "media_key"
      t.string  "media_url"
      t.string  "media_thumbnail_url"
      t.text    "media_embed"
    end
  end

  def self.down
    drop_table :external_videos
  end
end
