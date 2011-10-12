class CreateSoundcloudClients < ActiveRecord::Migration
  def self.up
    create_table :soundcloud_clients do |t|
      t.integer   :owner_id
      t.string    :owner_type
      t.string    :access_token
      t.string    :refresh_token
      t.datetime  :expires_at
      t.timestamps
    end
  end

  def self.down
    drop_table :soundcloud_clients
  end
end
