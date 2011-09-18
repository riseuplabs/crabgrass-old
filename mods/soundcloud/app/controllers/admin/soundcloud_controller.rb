class Admin::SoundcloudController < Admin::BaseController

  before_filter :get_client
  permissions 'admin/soundcloud'

  def new
    redirect_to remote.authorize_url(:display => "popup")
  end

  def show
    # actually this is a redirect after connecting
    if params[:error].nil? && params[:code]
      @client.destroy
      get_client
      remote.exchange_token(:code => params[:code])
    end
    if @client.connected?
      @me = remote.get '/me' rescue nil
    end
  end

  def destroy
    @client.destroy
    redirect_to :action => :show
  end

  protected

  def remote
    @client.remote(:redirect_uri => admin_soundcloud_url)
  end

  def get_client
    @client = current_site.soundcloud_client ||
      current_site.create_soundcloud_client
  end
end
