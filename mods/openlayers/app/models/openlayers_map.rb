class OpenlayersMap < ActiveRecord::Base

  attr_accessor :kml, :width, :height

  def initialize(kml, options={})
    @kml = kml
    @width = options[:width] || 250
    @height = options[:height] || 250
  end

end
