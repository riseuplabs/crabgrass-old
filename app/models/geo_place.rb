class GeoPlace < ActiveRecord::Base
  validates_presence_of :geo_country_id, :name
  belongs_to :geo_country
  belongs_to :geo_admin_code
  has_many :geo_locations
  has_many :profiles, :through => :geo_locations do

    # overwriting the named scope so we do not join profiles twice
    def visible_by(user, site = Site.current)
      self.find :all, :conditions => GeoPlace.conditions_for(user, site)
    end

    # this does not check for the site id of the groups.
    # we assume all members of a network are on the same site.
    def members_of(network, user = User.current)
      self.find :all, :conditions => GeoPlace.conditions_for(user, network)
    end
  end

  def group_profiles(user, site = Site.current)
    self.profiles.visible_by(user).collect{|profile| profile.entity}.uniq
  end

  named_scope :with_visible_groups, lambda {|user, site|
    { :joins => :profiles,
      :select => 'geo_places.*, count(*) as group_count',
      :group => 'geo_places.id',
      :conditions => GeoPlace.conditions_for(user,site) }
  }

  named_scope :with_groups_in, lambda {|network|
    { :conditions => ["profiles.group_id in (?)", network.group_ids] }
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

  # sql conditions for all places with visible groups in a given context
  # contexts need to respond to group_ids with a list of group ids
  # sites and networks do so.
  # one day this should be changed to return groups or users
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

  def longlat
    "#{longitude},#{latitude}"
  end
end
