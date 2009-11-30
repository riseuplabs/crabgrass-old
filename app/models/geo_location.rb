class GeoLocation < ActiveRecord::Base

  validates_presence_of :geo_country_id, :profile_id

  has_one :profile

  named_scope :countries_with_visible_profile, 
    :joins => 'join profiles on geo_locations.profile_id=profiles.id',
    :conditions => ["profiles.stranger = ? AND profiles.may_see = ?", true, true],
    :select => 'distinct geo_locations.geo_country_id'

  named_scope :admin_codes_with_visible_profile, lambda {|country_id|
    {
      :joins => 'join profiles on geo_locations.profile_id=profiles.id',
      :conditions => ["geo_country_id=? AND (profiles.stranger = ? AND profiles.may_see = ?)", country_id, true, true],
      :select => 'distinct geo_locations.geo_admin_code_id'
    }
  }

  named_scope :cities_with_visible_profile, lambda {|options|
    country_id = options[:country_id]
    admin_code_id = options[:admin_code_id]
    conditions = ["geo_country_id=? AND (profiles.stranger = ? AND profiles.may_see = ?)", country_id, true, true]
    if !admin_code_id.nil?
      conditions[0] << " AND geo_admin_code_id=?"
      conditions << admin_code_id
    end 
    { 
      :joins => 'join profiles on geo_locations.profile_id=profiles.id',
      :conditions => conditions,
      :select => 'distinct geo_locations.geo_place_id'
    }
  }


end
