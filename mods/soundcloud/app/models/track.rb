class Track < ActiveRecord::Base

  attr_accessible :title, :asset_data

  validates_presence_of :permalink_url
  validates_presence_of :title

  attr_accessor :asset_data

  def self.params_from_soundcloud(remote_track)
    remote_track.slice(:permalink_url, :title, :uri, :secret_uri)
  end

  before_validation :create_on_soundcloud
  def create_on_soundcloud
    soundcloud_track = client.remote.post '/tracks',
      :track => {:title => self.title,
        :sharing => 'private',
        :asset_data => File.new(asset_data.path)}
    self.permalink_url = soundcloud_track[:permalink_url]
    self.uri = soundcloud_track[:uri]
    self.secret_uri = soundcloud_track[:secret_uri]
  end

  before_update :update_on_soundcloud
  def update_on_soundcloud
    soundcloud_track = client.remote.put self.uri,
      :track => {:title => self.title,
        :sharing => 'private',
        :asset_data => File.new(asset_data.path)}
  end

  before_destroy :destroy_on_soundcloud
  def destroy_on_soundcloud
    client.remote.delete self.uri
  end

  protected

  def client
    Site.current.soundcloud_client ||
      Site.current.create_soundcloud_client
  end
end
