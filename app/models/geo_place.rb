class GeoPlace < ActiveRecord::Base
  validates_presence_of :geo_country_id, :name
  belongs_to :geo_country
  belongs_to :geo_admin_code
  has_many :geo_locations
  has_many :profiles, :through => :geo_locations

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

  # one day this should be changed to return groups or users
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
    { :joins => 'INNER JOIN profiles INNER JOIN groups ON (profiles.entity_id = groups.id AND profiles.entity_type = "Group")', #:groups,
      :select => 'profiles.*, count(*) as group_count',
      :conditions => conditions }
  }

  named_scope :with_groups_in, lambda {|group|
    ids = group.groups.map(&:id)
    conditions = ids.any? ? ["groups.id in (?)",ids] : "false"
    { :joins => :groups,
      :conditions => conditions }
  }

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

  def longlat
    "#{longitude},#{latitude}"
  end
end
