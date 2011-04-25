class RootController < ApplicationController

  javascript 'OpenLayers', 'OpenStreetMap', :plugin => 'openlayers'
  javascript "http://maps.google.com/maps/api/js?sensor=false"

end
