class GeoLocation < ActiveRecord::Base

  validates_presence_of :geo_country_id
  belongs_to :geo_country
  belongs_to :geo_place
  belongs_to :geo_admin_code

  belongs_to :profile

  def update_params(params)
    return unless params[:geo_country_id]
    if params[:geo_place_id] =~ /^\d+$/
      gp = GeoPlace.find(params[:geo_place_id])
    end
    self.geo_country = gp ? gp.geo_country : GeoCountry.find_by_id(params[:geo_country_id])
    self.geo_admin_code = gp ? gp.geo_admin_code : GeoAdminCode.find_by_id(params[:geo_admin_code])
    self.geo_place = gp
    self.save
  end

  named_scope :with_geo_place, :conditions => "geo_place_id != '' and geo_place_id is not null"

  named_scope :distinct, lambda{|which| {:group => which } }

end
