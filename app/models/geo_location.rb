class GeoLocation < ActiveRecord::Base

  validates_presence_of :geo_country_id
  belongs_to :geo_country
  belongs_to :geo_place
  belongs_to :geo_admin_code

  belongs_to :profile

  has_many :groups, :through => :profiles,
    :source => 'entity',
    :source_type => 'Group' do

    # overwriting the named scope so we do not join profiles twice
    def visible_by(user, site = Site.current)
      if user and user.real? and user.all_group_ids.any?
        conditions = <<-EOSQL
          ((profiles.stranger = #{true} AND profiles.may_see = #{true}) OR
            (groups.id IN (#{user.all_group_ids.join(',')}))) AND
          (groups.site_id = #{site.id})
        EOSQL
      else
        conditions = <<-EOSQL
          profiles.stranger = #{true} AND profiles.may_see = #{true} AND
          (groups.site_id = #{site.id})
        EOSQL
      end
      self.find :all, :conditions => conditions
    end

    def members_of(network, user = User.current)
      member_ids = network.groups.map(&:id)
      return [] if member_ids.empty?
      debugger
      if user and user.real? and user.all_group_ids.any?
        conditions = <<-EOSQL
          ((profiles.stranger = #{true} AND profiles.may_see = #{true}) OR
            ( groups.id IN (#{user.all_group_ids.join(',')}))) AND
          ( groups.id IN (#{member_ids.join(',')}))
        EOSQL
      else
        conditions = <<-EOSQL
          profiles.stranger = #{true} AND
          profiles.may_see = #{true} AND
          ( groups.id IN (#{member_ids.join(',')}))
        EOSQL
      end
      self.find :all, :conditions => conditions
    end
  end

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

  named_scope :with_groups_in, lambda {|group|
    ids = group.groups.map(&:id)
    conditions = ids.any? ? ["groups.id in (?)",ids] : "false"
    { :joins => :groups,
      :conditions => conditions }
  }
end
