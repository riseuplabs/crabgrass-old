require 'soundcloud'
class SoundcloudClient < ActiveRecord::Base

  include SoundcloudConfig

  attr_accessor :remote
  belongs_to :owner, :polymorphic => true

  def self.remote(options={})
    options = {
      :client_id     => CLIENT_ID,
      :client_secret => CLIENT_SECRET,
    }.merge options

    Soundcloud.new(options)
  end

  def remote(options = {})
    return @remote if @remote and options.empty?
    options={
      :expires_at    => expires_at,
      :access_token  => access_token,
      :refresh_token => refresh_token
    }.merge(options)
    @remote = self.class.remote(options)
    @remote.on_exchange_token do
      self.access_token = @remote.access_token
      self.refresh_token = @remote.refresh_token
      self.expires_at = @remote.expires_at
      self.save
    end
    @remote
  end

  def connected?
    !remote.access_token.nil?
  end

end
