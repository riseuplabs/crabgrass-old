class OpenlayersMap < ActiveRecord::Base

  attr_accessor :kml, :width, :height, :mapcenterlong, :mapcenterlat, :zoomlevel, :override_stylesheet

  def initialize(kml, options={})
    @kml = kml
    @width = options[:width] || 500
    @height = options[:height] || 355
    @mapcenterlat = options[:mapcenterlat] || -8
    @mapcenterlong = options[:mapcenterlong] || 8
    @zoomlevel = options[:zoomlevel] || 2 
    @override_stylesheet = options[:override_stylesheet] || nil
  end

end
