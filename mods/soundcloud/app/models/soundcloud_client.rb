require 'soundcloud'
class SoundcloudClient < ActiveRecord::Base

  attr_accessor :remote
  belongs_to :owner, :polymorphic => true

  CLIENT_ID = "eee3f3174759328707c73a0be2652fce"
  CLIENT_SECRET = "bce994a5f79e241cbe94e4035e4a224b"

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

  def connect(params = {})
    if params[:code] && params[:error].nil?
      remote.exchange_token(:code => params[:code]) rescue false
    elsif remote.expired?
      remote.exchange_token rescue false
    else
      !remote.access_token.nil?
    end
  end

end
