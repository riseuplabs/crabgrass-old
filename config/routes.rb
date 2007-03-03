ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'show'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # :defaults => {:file => nil},
  # :requirements => {:file => %r{[^/]+(\.[^/]+)?}}
  
  # perhaps use nested routes instead?
  # http://www.artofmission.com/articles/2006/10/12/nested-routes-using-map-resources
  
  for page in PAGE_TYPES
    map.connect ":from/:from_id/#{page}/:action/:id",
     :from => /groups|me|people|networks|places/,
     :controller => "pages/#{page}",
     :action => 'show'
  end

  # so we can use named urls
  map.people 'people/:action/:id', :controller => 'people'
  map.groups 'groups/:action/:id', :controller => 'groups'
  map.me 'me/:action/:id', :controller => 'me'

  map.group 'groups/:action/:id', :controller => 'groups'
  
  #map.avatar 'avatar/:viewable_type/:viewable_id/:size',
  #   :controller => 'avatars', :action => 'show', :viewable_id => /\d+/,
  #   :viewable_type => /(group|user)/
  
  map.avatar 'avatars/:id/:size/image.jpg', :action => 'show', :controller => 'avatars'
  #    :size => /(xsmall|small|medium|large|xlarge)/, :id => 0
  
  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "account"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
