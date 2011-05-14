// loading the map in combination with the openlayers_js
var loadMap = function() {
  var map;
  var base;
  var layers = new Array();
  var options;
  var controls = [ new OpenLayers.Control.Navigation({zoomWheelEnabled: false}),
    new OpenLayers.Control.PanZoom(),
    new OpenLayers.Control.LayerSwitcher({autoActive: true}),
    new OpenLayers.Control.Attribution()];
      
  var base_el;
  base_el = $$('#map-base').first();
  if (base_el != null) {
    var base_provider = base_el.readAttribute('data-provider');
    // TODO: Actually select based on the provider
    base = new OpenLayers.Layer.Google("Google Streets");
    options = {
      numZoomLevels: 20,
      controls: controls
    };
  } else {
    base = new OpenLayers.Layer.OSM();
    options = {
      theme: false,
      maxExtent: new OpenLayers.Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34),
      numZoomLevels: 19,
      maxResolution: 156543.0399,
      units: 'm',
      projection: new OpenLayers.Projection("EPSG:900913"),
      displayProjection: new OpenLayers.Projection("EPSG:4326"),
      controls: controls
    };
  }
  map = new OpenLayers.Map('map', options);
  map.addLayer(base);
  var layer_elements = $$(".layer");
  layer_elements.each( function(l) {
    var label = l.readAttribute('data-label');
    var url = l.readAttribute('data-url');
    var layer = new OpenLayers.Layer.GML(label, url, 
      {
        format: OpenLayers.Format.KML, 
        formatOptions: {
        extractStyles: true, 
        extractAttributes: true
        },
        projection: map.displayProjection
      });
    // Events for the objects of the KML-Data
    layer.events.on({
      'featureselected': onFeatureSelect,
      'featureunselected': onFeatureUnselect
    });
    layers.push(layer)
  });
  map.addLayers(layers);
  var control = new OpenLayers.Control.SelectFeature(layers);
  map.addControl(control);
  control.activate();
           
  map.addControl(new OpenLayers.Control.LayerSwitcher());

  var center = $$('#map-center').first()
  var long = center.readAttribute('data-long');
  var lat = center.readAttribute('data-lat');
  var lonLat = new OpenLayers.LonLat(long, lat).transform(
      new OpenLayers.Projection("EPSG:4326"),
      map.getProjectionObject());
  map.setCenter (lonLat, 2); 

  function onPopupClose(evt) {
    control.unselect(this.feature);
  }
  function onFeatureSelect(evt) {
    feature = evt.feature;
			popup_description = feature.attributes.description;
    popup = new OpenLayers.Popup.FramedCloud("featurePopup",
      feature.geometry.getBounds().getCenterLonLat(),
      new OpenLayers.Size(200,200),
				// if the description is an ajax call, this just adds a div that can be populated
				renderKMLDescription(popup_description),
      null, true, onPopupClose);
    feature.popup = popup;
    popup.feature = feature;
			// if the description is an ajax call, run the ajax request 
			// and show the marker on success 
			map.addPopup(popup);
			if (match = popup_description.match(/^ajax:(.*)$/)) {
				new Ajax.Request(match[1], {
					method: 'get',
					onLoading: function() {
						$('popup_spinner').show();
					},
				  onComplete: function() {
						$('popup_spinner').hide();
					}
				});
			}else {
				// otherwise just show the marker
				map.addPopup(popup);
			}
  }
  function renderKMLDescription(desc) {
			var match = [];
			if (match = desc.match(/^ajax:/)) {
				return '<div id="popup_entities_list"><img src="/images/spinner.gif" id="popup_spinner" style="display:none;"></div>'
			}else {
				return desc;
			}
		}
  function onFeatureUnselect(evt) {
    feature = evt.feature;
    if (feature.popup) {
      popup.feature = null;
      map.removePopup(feature.popup);
      feature.popup.destroy();
      feature.popup = null;
    }
  }
  //map.zoomToMaxExtent();
  var zoom = $$('#map-zoom').first()
  var level = zoom.readAttribute('data-level');
  map.zoomTo(level);
} 
