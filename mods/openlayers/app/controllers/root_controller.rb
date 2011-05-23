class RootController < ApplicationController

  helper 'map'
  javascript 'OpenLayers', 'OpenStreetMap', 'Map', :plugin => 'openlayers'

end
