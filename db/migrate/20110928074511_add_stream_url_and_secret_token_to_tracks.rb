class AddStreamUrlAndSecretTokenToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :stream_url, :string
    add_column :tracks, :secret_token, :string
  end

  def self.down
    remove_column :tracks, :secret_token
    remove_column :tracks, :stream_url
  end
end
