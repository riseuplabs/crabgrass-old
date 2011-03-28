class OpenlayersMap < ActiveRecord::Base

  attr_accessor :kml, :width, :height, :mapcenterlong, :mapcenterlat, :zoomlevel

  def initialize(kml, options={})
    @kml = kml
    defaults = {
      :width => 500,
      :height => 355,
      :mapcenterlong => -8,
      :mapcenterlat => 8,
      :zoomlevel => 2
    }
    defaults.merge!(options)
    [:width, :height, :mapcenterlat, :mapcenterlong, :zoomlevel].each do |z|
      self.instance_variable_set(z.to_s, defaults[z])
    end
  end

end
