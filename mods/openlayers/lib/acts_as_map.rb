module ActsAsMap

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def acts_as_map(options = {})
      cattr_accessor :override_stylesheets, :map_partial, :kml_location
      self.map_override_stylesheets = ''
      self.map_partial = options[:map_partial] || '/locations/map'
      send :include, InstanceMethods
    end
  end

  module InstanceMethods
    def kml_location(url)
      write_attribute(self.kml_location)
    end
    
  end

end

ActiveRecord::Base.send :include, ActsAsMap

@map = Widget.new
display_map(@map)

#what we want:
#* a way to specify override stylesheets
#* a way to specify kml
#* a way to render the map template
#* a way to load helpers into controllers
