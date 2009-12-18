class GeoPlace < ActiveRecord::Base
  validates_presence_of :geo_country_id, :name
  belongs_to :geo_country
  belongs_to :geo_admin_code

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

end
