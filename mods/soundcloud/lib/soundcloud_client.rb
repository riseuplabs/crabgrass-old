require 'soundcloud'

class SoundcloudClient

  attr_accessor :connection

  def options
    config.slice :client_id, :client_secret,
      :refresh_token, :expires_at, :access_token
  end

  def config
    site = Site.current
    return {} if site.nil?
    site.evil.respond_to?(:[]) ? site.evil["soundcloud"] : {}
  end

  def initialize
    @connection = Soundcloud.new(options)
    update_config
    @connection.on_exchange_token do
      update_config
    end
  end

  def update_config
    config[:access_token] = @connection.access_token
    config[:refresh_token] = @connection.refresh_token
    config[:expires_at] = @connection.expires_at
  end
end
