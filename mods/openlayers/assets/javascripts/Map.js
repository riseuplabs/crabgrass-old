// loading the map in combination with the openlayers_js
var loadMap = function() {
  var base_el = $('#map-base');
  var base_provider;
  if (base_el != null) {
    base_provider = base_el.readAttribute('data-provider');
  } else {
    base_provider = 'OSM'
  }
  var map = new OpenLayers.Map('map', optionsForProvider(base_provider));
  map.addLayer(baseLayerForProvider(base_provider));
  addControls(map)

  var layers = new Array();
  var layer_elements = $$(".layer");
  layer_elements.each( function(l) {
    var label = l.readAttribute('data-label');
    var url = l.readAttribute('data-url');
    layers.push(createLayer(label, url, map.displayProjection));
  });
  map.addLayers(layers);
  var control = new OpenLayers.Control.SelectFeature(layers);
  map.addControl(control);
  control.activate();
           
  var center = $$('#map-center').first()
  var long = center.readAttribute('data-long');
  var lat = center.readAttribute('data-lat');
  var lonLat = new OpenLayers.LonLat(long, lat).transform(
      new OpenLayers.Projection("EPSG:4326"),
      map.getProjectionObject());
  map.setCenter (lonLat, 2); 

  //map.zoomToMaxExtent();
  var zoom = $$('#map-zoom').first()
  var level = zoom.readAttribute('data-level');
  map.zoomTo(level);

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

  function optionsForProvider(provider) {
    if (provider == 'google') {
      options = {
        numZoomLevels: 20,
        controls: []
      };
    } else {
      options = {
        theme: false,
        maxExtent: new OpenLayers.Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34),
        numZoomLevels: 19,
        maxResolution: 156543.0399,
        units: 'm',
        projection: new OpenLayers.Projection("EPSG:900913"),
        displayProjection: new OpenLayers.Projection("EPSG:4326"),
        controls: []
      };
    }
    return options;
  }

  function baseLayerForProvider(provider) {
    if (provider == 'google') {
      base = new OpenLayers.Layer.Google("Google Streets");
    } else {
      base = new OpenLayers.Layer.OSM('OSM',
        'http://tile.openstreetmap.org/${z}/${x}/${y}.png',
        {'displayInLayerSwitcher':false});
    }
    return base;
  }
  
  function addControls(map) {
    map.addControl( new OpenLayers.Control.Navigation({zoomWheelEnabled: false}) );
    map.addControl( new OpenLayers.Control.PanZoom() );
    map.addControl( new OpenLayers.Control.Attribution() );
    map.addControl( new CustomizedLayerSwitcher({
      'div':OpenLayers.Util.getElement('map-container'),
      'roundedCorner': false}));
  }

  
  function createLayer(label, url, projection) {
    var layer = new OpenLayers.Layer.GML(label, url, 
      {
        format: OpenLayers.Format.KML, 
        formatOptions: {
        extractStyles: true, 
        extractAttributes: true
        },
        projection: projection
      });
    // Events for the objects of the KML-Data
    layer.events.on({
      'featureselected': onFeatureSelect,
      'featureunselected': onFeatureUnselect
    });
    return layer;
  }
}

CustomizedLayerSwitcher =
  OpenLayers.Class(OpenLayers.Control.LayerSwitcher, {
  
    /** 
     * Method: redraw
     *
     * Changes:
     *  *  Add a class layer_c to each layer where c is the index of the layer
     */  
    redraw: function() {
        OpenLayers.Control.LayerSwitcher.prototype.redraw.apply(this, arguments);
        this.addLabelClasses();
        this.removeLineBreaks();
        return this.div;
    },

    addLabelClasses: function() {
      var label_div = this.div.select('.dataLayersDiv').first();
      var index = 0;
      label_div.select('span').each( function (label) {
        index = index + 1;
        label.addClassName('layer_' + index);
      });
      label_div.select('input').each( function (input) {
        input.addClassName('checkbox');
      });
    },

    removeLineBreaks: function() {
      var label_div = this.div.select('.dataLayersDiv').first();
      var breaks = label_div.select('br');
      breaks.each( function (br) { br.remove() });
    },
      

    CLASS_NAME: "CustomizedLayerSwitcher"
});
