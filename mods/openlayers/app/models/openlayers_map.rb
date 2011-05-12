class OpenlayersMap

  attr_accessor :kml, :width, :height, :mapcenterlong, :mapcenterlat, :zoomlevel, :override_stylesheet

  def initialize(options={})
    @width = options[:width] || 500
    @height = options[:height] || 355
    @mapcenterlat = options[:mapcenterlat] || -8
    @mapcenterlong = options[:mapcenterlong] || 8
    @zoomlevel = options[:zoomlevel] || 2 
    @override_stylesheet = options[:override_stylesheet] || nil
  end

  def map_partial
    '/locations/map'
  end

end
