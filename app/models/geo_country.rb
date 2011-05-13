class GeoCountry < ActiveRecord::Base
  validates_presence_of :name, :code
  validates_uniqueness_of :name, :code
  has_many :geo_admin_codes
  has_many :geo_places
  has_many :geo_locations
  has_many :profiles, :through => :geo_locations do

    # overwriting the named scope so we do not join profiles twice
    def visible_by(user, site = Site.current)
      self.find :all, :conditions => GeoCountry.conditions_for(user, site)
    end

    # this does not check for the site id of the groups.
    # we assume all members of a network are on the same site.
    def members_of(network, user = User.current)
      self.find :all, :conditions => GeoCountry.conditions_for(user, network)
    end
  end

  def group_profiles(user, site = Site.current)
    group_ids = self.profiles.visible_by(user).collect{|p| p.entity_id}.uniq
    Group.with_ids(group_ids)
  end

  named_scope :with_public_profile, 
    :joins => 'as gc join geo_locations as gl on gc.id = gl.geo_country_id',
    :select => 'gc.name, gc.id'

  def self.conditions_for(user, context)
    if user and user.real? and my_group_ids = Group.namespace_ids(user.all_group_ids)
      sql = <<-EOSQL
        ((profiles.stranger = ? AND profiles.may_see = ? ) OR
          (profiles.entity_id IN (?))) AND
        (profiles.entity_id IN (?)) AND
        profiles.entity_type = 'Group'
      EOSQL
      [sql, true, true, my_group_ids, context.group_ids]
    else
      sql = <<-EOSQL
        profiles.stranger = ? AND
        profiles.may_see = ? AND
        profiles.entity_id IN (?) AND
        profiles.entity_type = 'Group'
      EOSQL
      [sql, true, true, context.group_ids]
    end
  end

end
