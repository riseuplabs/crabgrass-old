class AddSecretUriToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :secret_uri, :string
  end

  def self.down
    remove_column :tracks, :secret_uri
  end
end
