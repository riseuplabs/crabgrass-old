class AssetsBundleController < ActionController::Base
  caches_page :fetch
  
  def fetch
    bundle = AssetsBundle.new(params['names'], params['ext'])
    headers['Content-Type'] = bundle.content_type
    render :text => bundle.content || ''
  end  
end