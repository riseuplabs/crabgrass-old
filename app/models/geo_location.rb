class GeoLocation < ActiveRecord::Base

  validates_presence_of :geo_country_id
  belongs_to :geo_country
  belongs_to :geo_place

  has_many :profiles

  has_many :groups, :through => :profiles,
    :source => 'entity',
    :source_type => 'Group' do

    # overwriting the named scope so we do not join profiles twice
    def visible_by(user)
      if user and user.real? and user.all_group_ids.any?
        conditions = <<-EOSQL
          (profiles.stranger = #{true} AND profiles.may_see = #{true}) OR
          ( profiles.entity_type = 'Group' AND
            profiles.entity_id IN (#{user.all_group_ids.join(',')}))
        EOSQL
      else
        conditions = <<-EOSQL
          profiles.stranger = #{true} AND profiles.may_see = #{true}
        EOSQL
      end
      self.find :all, :conditions => conditions
    end
  end

  named_scope :with_geo_place, :conditions => "geo_place_id != '' and geo_place_id is not null"

  named_scope :with_visible_groups, lambda {|user, site|
    if user and user.real? and my_group_ids = Group.namespace_ids(user.all_group_ids)
      sql = <<-EOSQL
        ((profiles.stranger = ? AND profiles.may_see = ? ) OR
          (groups.id IN (?))) AND
        (groups.site_id = ?)
      EOSQL
      conditions = [sql, true, true, my_group_ids, site.id]
    else
      sql = <<-EOSQL
        profiles.stranger = ? AND
        profiles.may_see = ? AND
        groups.site_id = ?
      EOSQL
      conditions = [sql, true, true, site.id]
    end
    { :joins => :groups,
      :select => 'geo_locations.*, count(*) as group_count',
      :group => 'geo_locations.geo_place_id',
      :conditions => conditions }
  }

end
