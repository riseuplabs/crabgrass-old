class Admin::SoundcloudController < ApplicationController

  before_filter :get_client

  def new
    redirect_to @client.connection.authorize_url(:display => "popup")
  end

  def show
    # actually this is a redirect after connecting
    if params[:error].nil? && params[:code]
      @client.connection.exchange_token(:code => params[:code])
    end
    @me = @client.connection.get '/me'
  end

  protected

  def get_client
    @client = SoundcloudClient.new(:redirect_uri  => admin_soundcloud_url)
  end
end
