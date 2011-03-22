class GeoPlace < ActiveRecord::Base
  validates_presence_of :geo_country_id, :name
  belongs_to :geo_country
  belongs_to :geo_admin_code

  named_scope :named_like, lambda {|query|
    single = "#{query}%"
    multi = "%,#{query}%"
    { :conditions => ["name LIKE ? OR alternatenames LIKE ?", single, multi] }
  }

  named_scope :largest, lambda {|count|
    { :order => "population DESC", :limit => count }
  }

  def self.with_names_matching(name, country_id, params={})
    geo_country = GeoCountry.find(country_id)
    if params[:admin_code_id] =~ /\d+/
      geo_admin_code = geo_country.geo_admin_codes.find(params[:admin_code_id])
      admin_codes = [geo_admin_code]
    else
      admin_codes = geo_country.geo_admin_codes.find(:all)
    end
    @places = []
    admin_codes.each do |ac|
      ### first search for exact- return that if found
      places = ac.geo_places.find_by_name(name)
      if places.is_a?(Array)
        places.each do |place|
          @places << place
        end
      elsif ! places.nil?
        @places << places
      end
    end
    return @places unless (@places.empty? or params[:search_alternates])
    ### search for LIKE in name and alternatenames
    admin_codes.each do |ac|
      @places << find(:all,
        :conditions=>['geo_admin_code_id = ? and (name LIKE ? or alternatenames LIKE ?)', ac.id, "%#{name}%", "%,#{name},%"]
      )
    end
    return @places.flatten!
  end

  def self.sort_entities_by_place(entities)
    places = {}
    entities.each do |ent|
      data = {}
      next unless data = GeoPlace.geo_data_for_kml(ent)
      next unless data[:lat] and data[:long]
      id = data[:geo_place_id]
      places[id] ||= {}
      places[id][:longlat] ||= "#{data[:long]},#{data[:lat]}"
      places[id][:name] ||= data[:geo_place_name]
      places[id][:collection] ||= []
      places[id][:collection] << ent
    end
    return places
  end

  def self.geo_data_for_kml(entity)
    # currently groups are only supported. when users are added the profile
    # would be entity.profile (groups location data is only stored in the public profile)
    if entity.is_a?(Group)
      profile = entity.profiles.public
      description_template = 'locations/description_for_kml.html.haml'
    end
    return false unless profile and profile.city_id
    return false unless place = GeoPlace.find(profile.city_id)
    data = {}
    data[:name] = entity.try(:display_name) || entity.name
    data[:geo_place_id] = place.id
    data[:geo_place_name] = place.name
    data[:description_template] = description_template
    data[:lat] = place.latitude
    data[:long] = place.longitude
    return data
  end

end
