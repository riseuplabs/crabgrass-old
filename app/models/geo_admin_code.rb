class GeoAdminCode < ActiveRecord::Base
  validates_presence_of :geo_country_id, :admin1_code, :name
  belongs_to :geo_country
  has_many :geo_places

  named_scope :with_public_profile, lambda {|country_id| 
    {
      :joins => 'as gac join geo_locations as gl on gac.id = gl.geo_admin_code_id',
      :conditions => ['gl.geo_country_id = ?', country_id],
      :select => 'gac.id, gac.name'
    }
  }

end
