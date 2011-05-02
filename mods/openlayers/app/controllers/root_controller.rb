class RootController < ApplicationController

  helper 'map'
  javascript 'OpenLayers', 'OpenStreetMap', :plugin => 'openlayers'

end
