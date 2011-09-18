class Track < ActiveRecord::Base

  has_one :showing
  has_one :gallery, :through => :showing
  has_one :image, :through => :showing

  attr_accessible :title, :asset_data

  validates_presence_of :permalink_url
  validates_presence_of :title

  attr_accessor :asset_data

  def self.params_from_soundcloud(remote_track)
    remote_track.slice(:permalink_url, :title, :uri, :secret_uri)
  end

  before_validation :create_or_update_on_soundcloud
  def create_or_update_on_soundcloud
    if self.new_record?
      soundcloud_track = client.remote.post '/tracks',
        :track => self.track_hash
    else
      debugger
      soundcloud_track = client.remote.put self.uri,
        :track => self.track_hash
    end
    self.permalink_url = soundcloud_track[:permalink_url]
    self.uri = soundcloud_track[:uri]
    self.secret_uri = soundcloud_track[:secret_uri]
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

  def track_hash
    hash = { :title => self.image.caption,
      :sharing => 'private'}
    asset_data.length == 0 ?
      hash :
      hash.merge(:asset_data => File.new(asset_data.path))
  end

end
