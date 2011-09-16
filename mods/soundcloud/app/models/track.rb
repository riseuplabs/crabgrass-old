class Track < ActiveRecord::Base

  validates_presence_of :permalink_url
  validates_presence_of :title

  attribute_accessor :asset_data

  def self.params_from_soundcloud(remote_track)
    remote_track.slice(:permalink_url, :title, :uri, :secret_uri)
  end

  before_create :create_on_soundcloud
  def create_on_soundcloud
    soundcloud_track = client.remote.post '/tracks',
      :track => {:title => self.title,
        :sharing => 'private',
        :asset_data => File.new(asset_data.path)}
    self.permalink_url = soundcloud_track[:permalink_url]
    self.uri = soundcloud_track[:uri]
    self.secret_uri = soundcloud_track[:secret_uri]
  end

  protected

  def client
    Site.current.soundcloud_client ||
      Site.current.create_soundcloud_client
  end
end
