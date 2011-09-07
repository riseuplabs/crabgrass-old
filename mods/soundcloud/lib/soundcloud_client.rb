require 'soundcloud'

class SoundcloudClient


  CLIENT_ID = "eee3f3174759328707c73a0be2652fce"
  CLIENT_SECRET = "bce994a5f79e241cbe94e4035e4a224b"

  attr_accessor :connection

  def config_options
    options = {
      :client_id     => CLIENT_ID,
      :client_secret => CLIENT_SECRET,
    }
    options.merge config.slice(:client_id, :client_secret,
      :refresh_token, :expires_at, :access_token)
  end

  def config
    site = Site.current
    return {} if site.nil?
    site.evil['soundcloud'] ||= {}
  end

  def initialize(options = {})
    @connection = Soundcloud.new(config_options.merge options)
    update_config
    @connection.on_exchange_token do
      update_config
    end
  rescue ArgumentError
  end

  def update_config
    config[:access_token] = @connection.access_token
    config[:refresh_token] = @connection.refresh_token
    config[:expires_at] = @connection.expires_at
  end
end
