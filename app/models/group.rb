=begin
create_table "groups", :force => true do |t|
  t.string   "name"
  t.string   "full_name"
  t.string   "summary"
  t.string   "url"
  t.string   "type"
  t.integer  "parent_id",  :limit => 11
  t.integer  "council_id", :limit => 11
  t.datetime "created_at"
  t.datetime "updated_at"
  t.integer  "avatar_id",  :limit => 11
  t.string   "style"
  t.string   "language",   :limit => 5
  t.integer  "version",    :limit => 11, :default => 0
  t.integer  "min_stars",  :limit => 11, :default => 1
  t.integer  "site_id",    :limit => 11
end

  associations:
  group.children   => groups
  group.parent     => group
  group.council  => nil or group
  group.users      => users
=end

class Group < ActiveRecord::Base

  # core group extentions
  include GroupExtension::Groups     # group <--> group behavior
  include GroupExtension::Users      # group <--> user behavior
  include GroupExtension::Featured   # this makes this group's pages featureable
  include GroupExtension::Pages      # group <--> page behavior

  acts_as_site_limited

  attr_accessible :name, :full_name, :short_name, :summary, :language, :avatar

  # not saved to database, just used by activity feed:
  attr_accessor :created_by, :destroyed_by

  # group <--> chat channel relationship
  has_one :chat_channel

  ##
  ## FINDERS
  ##

  # finds groups that user may see
  named_scope :visible_by, lambda { |user|
    group_ids = user && user.real? ? Group.namespace_ids(user.all_group_ids) : []
    # The grouping serves as a distinct.
    # A DISTINCT term in the select seems to get striped of by rails.
    # The other way to solve duplicates would be to put profiles.friend = true
    # in other side of OR
    {:include => :profiles, :group => "groups.id", :conditions => ["(profiles.stranger = ? AND profiles.may_see = ?) OR (groups.id IN (?))", true, true, group_ids]}
  }

  named_scope :without_member, lambda { |user|
    group_ids = user.group_ids
    group_ids.any? ?
      {:conditions => ["NOT groups.id IN (?)", group_ids]} :
      {}
  }

  named_scope :public,
    :include => :profiles,
    :conditions => ["(profiles.stranger = ? AND profiles.may_see = ?)", true, true]

  # finds groups that are of type Group (but not Committee or Network)
  named_scope :only_groups, :conditions => 'groups.type IS NULL'

  named_scope :only_type, lambda { |group_type|
    group_type = group_type.to_s.capitalize
    if group_type == 'Group'
      {:conditions => 'groups.type IS NULL'}
    else
      {:conditions => ['groups.type = ?', group_type]}
    end
  }

  named_scope :without_site_network, lambda {
    if Site.current && network_id = Site.current.network_id
      {:conditions => ['groups.id != ?', network_id]}
    else
      {}
    end
  }

  named_scope :all_networks_for, lambda { |user|
    {:conditions => ["groups.type = 'Network' AND groups.id IN (?)", user.all_group_id_cache]}
  }

  named_scope :alphabetized, lambda { |letter|
    opts = {
      :order => 'groups.full_name ASC, groups.name ASC'
    }

    if letter == '#'
      opts[:conditions] = ['(groups.full_name REGEXP ? OR groups.name REGEXP ?)', "^[^a-z]", "^[^a-z]"]
    elsif not letter.blank?
      opts[:conditions] = ['(groups.full_name LIKE ? OR groups.name LIKE ?)', "#{letter}%", "#{letter}%"]
    end

    opts
  }

  named_scope :recent, :order => 'groups.created_at DESC', :conditions => ["groups.created_at > ?", RECENT_SINCE_TIME]
  named_scope :by_created_at, :order => 'groups.created_at DESC'

  named_scope :names_only, :select => 'full_name, name'

  # filters the groups based on their name and full name
  # filter is a sql query string
  named_scope :named_like, lambda { |filter|
    { :conditions => ["(groups.name LIKE ? OR groups.full_name LIKE ? )",
            filter, filter] }
  }

  named_scope :with_ids, lambda { |ids|
    {:conditions => ['groups.id IN (?)', ids]}
  }


    LOCATIONS_JOIN = <<EOSQL
INNER JOIN `geo_locations`
  ON (`geo_locations`.`profile_id` = `profiles`.`id`)
EOSQL

  # this only works together with a scope that joins in the profiles
  # usually this will be visible_by
  named_scope :located_in, lambda { |params|
    if params.slice(:country_id, :state_id, :city_id).any?
      { :joins => LOCATIONS_JOIN, 
        :conditions => Group.conditions_for_location(params)
      }
    else
      {}
    end
  }

  ##
  ## GROUP INFORMATION
  ##

  include CrabgrassDispatcher::Validations
  validates_handle :name
  before_validation :clean_names

  def clean_names
    t_name = read_attribute(:name)
    if t_name
      write_attribute(:name, t_name.downcase)
    end

    t_name = read_attribute(:full_name)
    if t_name
      write_attribute(:full_name, t_name.gsub(/[&<>]/,''))
    end
  end

  # the code shouldn't call find_by_name directly, because the group name
  # might contain a space in it, which we store in the database as a plus.
  def self.find_by_name(name)
    return nil unless name.any?
    Group.find(:first, :conditions => ['groups.name = ?', name.gsub(' ','+')])
  end

  # name stuff
  def to_param; name; end
  def display_name; full_name.any? ? full_name : name; end
  def short_name; name; end
  def cut_name; name[0..20]; end
  def both_names
    return name if name == display_name
    return "%s (%s)" % [display_name, name]
  end

  # visual identity
  def banner_style
    @style ||= Style.new(:color => "#eef", :background_color => "#1B5790")
  end

  # type of group
  def committee?; instance_of? Committee; end
  def network?;   instance_of? Network;   end
  def normal?;    instance_of? Group;     end
  def council?;   instance_of? Council;   end

  def group_type; I18n.t(self.class.name.downcase.to_sym); end

  ##
  ## PROFILE
  ##

  has_many :profiles, :as => 'entity', :dependent => :destroy, :extend => ProfileMethods

  has_many :geo_locations, :through => :profiles

  def profile
    self.profiles.visible_by(User.current)
  end


  ##
  ## AVATAR
  ##

  belongs_to :avatar, :dependent => :destroy

  alias_method 'avatar_equals', 'avatar='
  def avatar=(data)
    if data.is_a? Avatar
      avatar_equals data
    elsif data.is_a? Hash
      if avatar_id
        avatar.image_file = data[:image_file]
        avatar.image_file_data_will_change!
      else
        avatar_equals Avatar.new(data)
      end
    end
  end

  def destroy_by(user)
    # needed for the activity
    self.destroyed_by = user
    self.council.destroyed_by = user if self.council
    self.children.each {|committee| committee.destroyed_by = user}

    self.destroy
  end

  ##
  ## PERMISSIONS
  ##

  def may_be_pestered_by?(user)
    begin
      may_be_pestered_by!(user)
    rescue PermissionDenied
      false
    end
  end

  ## TODO: change may_see? to may_pester?
  def may_be_pestered_by!(user)
    if user.member_of?(self) or profiles.visible_by(user).may_see?
      return true
    else
      raise PermissionDenied.new(I18n.t(:share_pester_error, :name => self.name))
    end
  end

  # if user has +access+ to group, return true.
  # otherwise, raise PermissionDenied
  def has_access!(access, user)
    if access == :admin
      ok = user.member_of?(self.council)
    elsif access == :edit
      ok = user.member_of?(self) || user.member_of?(self.council)
    elsif access == :view
      ok = user.member_of?(self) || profiles.public.may_see?
    end
    ok or raise PermissionDenied.new
  end

  def has_access?(access, user)
    return has_access!(access, user)
  rescue PermissionDenied
    return false
  end

  ##
  ## GROUP SETTINGS
  ##

  has_one :group_setting
  # can't remember the way to do this automatically
  after_create :create_group_setting
  def create_group_setting
    self.group_setting = GroupSetting.new
    self.group_setting.save
  end

  #Defaults!
  def tool_allowed(tool)
    group_setting.allowed_tools.nil? or group_setting.allowed_tools.index(tool)
  end

  #Defaults!
  def layout(section)
    template_data = (group_setting || GroupSetting.new).template_data || {"section1" => "group_wiki", "section2" => "recent_pages"}
    template_data[section]
  end

  protected

  before_save :save_avatar_if_needed
  def save_avatar_if_needed
    avatar.save if avatar and avatar.changed?
  end

  # make destroy protected
  # callers should use destroy_by
  def destroy
    super
  end

  ##
  ## RELATIONSHIP TO ASSOCIATED DATA
  ##

  after_destroy :destroy_requests
  def destroy_requests
    Request.destroy_for_group(self)
  end

  after_destroy :update_networks
  def update_networks
    self.networks.each do |network|
      Group.increment_counter(:version, network.id)
    end
  end

  after_save :update_name_copies

  # if our name has changed, ensure that denormalized references
  # to it also get changed
  def update_name_copies
    if name_changed? and !name_was.nil?
      Page.update_owner_name(self)
      Wiki.clear_all_html(self)   # in case there were links using the old name
      # update all committees (this will also trigger the after_save of committees)
      committees.each {|c|
        c.parent_name_changed
        c.save if c.name_changed?
      }
      User.increment_version(self.user_ids)
    end
  end


  def self.conditions_for_location(params)
    param_to_column_map = { 
      :country_id => 'geo_country_id',
      :state_id => 'geo_admin_code_id',
      :city_id => 'geo_place_id' }
    param_to_column_map.inject({}) do |cond, (param, column)|
      cond["geo_locations.#{column}"] = params[param] if params[param]
      cond
    end
  end

end
