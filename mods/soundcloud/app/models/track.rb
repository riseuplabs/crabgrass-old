class Track < ActiveRecord::Base

  validates_presence_of :permalink_url

  def self.params_from_soundcloud(remote_track)
    remote_track.slice(:permalink_url, :title, :uri, :secret_uri)
  end
end
