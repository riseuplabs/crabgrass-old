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
  t.boolean  "is_council",               :default => false
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

  # returns true if self is part of a specific network
  def belongs_to_network?(network)
    ( self.networks.include?(network) or 
      self == network )
  end
  
  named_scope :visible_on, lambda { |site| 
    site.network.nil? ? 
      {} :
      { :conditions => ["groups.id IN (?) OR groups.parent_id IN (?)",
        site.network.group_ids, site.network.group_ids] }
  }
  
  
  attr_accessible :name, :full_name, :short_name, :summary, :language

  # not saved to database, just used by activity feed:
  attr_accessor :created_by, :destroyed_by

  ##
  ## FINDERS
  ## 

  # finds groups that user may see
  named_scope :visible_by, lambda { |user|
    group_ids = user ? Group.namespace_ids(user.all_group_ids) : []
    joins = "LEFT OUTER JOIN profiles ON profiles.entity_id = groups.id AND profiles.entity_type = 'Group'"
    # The grouping serves as a distinct.
    # A DISTINCT term in the select seems to get striped of by rails.
    # The other way to solve duplicates would be to put profiles.friend = true
    # in other side of OR
    {:joins => joins, :group => "groups.id", :conditions => ["(profiles.stranger = ? AND profiles.may_see = ?) OR (groups.id IN (?))", true, true, group_ids]}
  }

  # finds groups that are of type Group (but not Committee or Network)
  named_scope :only_groups, :conditions => 'groups.type IS NULL'

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

  named_scope :names_only, :select => 'full_name, name'


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

  belongs_to :avatar
  has_many :profiles, :as => 'entity', :dependent => :destroy, :extend => ProfileMethods
  
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
   
  def committee?; instance_of? Committee; end
  def network?; instance_of? Network; end
  def normal?; instance_of? Group; end  
  def display_type() self.class.to_s.downcase; end
 
  ##
  ## RELATIONSHIP TO ASSOCIATED DATA
  ## 

  after_destroy :destroy_requests
  def destroy_requests
    Request.destroy_for_group(self)
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
  
  def may_be_pestered_by!(user)
    if user.member_of?(self) or publicly_visible_group or (parent and parent.publicly_visible_committees and parent.may_be_pestered_by?(user))
      return true
    else
      raise PermissionDenied.new('You are not allowed to share with %s'[:pester_denied] % self.name)
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
    elsif access == :view_membership
      ok = user.member_of?(self) || self.has_access!(:admin,user) || profiles.visible_by(user).may_see_members?
    end
    ok or raise PermissionDenied.new
  end

  def has_access?(access, user)
    return has_access!(access, user)
  rescue PermissionDenied
    return false
  end
  
  ##
  ## temp stuff for profile transition
  ## should be removed eventually
  ##

  def publicly_visible_group
    profiles.public.may_see?
  end
  def publicly_visible_group=(val)
    profiles.public.update_attribute :may_see, val
  end

  def publicly_visible_committees
    profiles.public.may_see_committees?
  end
  def publicly_visible_committees=(val)
    profiles.public.update_attribute :may_see_committees, val
  end

  def publicly_visible_members
    profiles.public.may_see_members?
  end
  def publicly_visible_members=(val)
    profiles.public.update_attribute :may_see_members, val
  end

  def accept_new_membership_requests
    profiles.public.may_request_membership?
  end
  def accept_new_membership_requests=(val)
    profiles.public.update_attribute :may_request_membership, val
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
  
  after_save :update_name
  def update_name
    if name_changed?
      update_group_name_of_pages  # update cached group name in pages
      Wiki.clear_all_html(self)   # in case there were links using the old name
      # update all committees (this will also trigger the after_save of committees)
      committees.each {|c| c.parent_name_changed }
      User.increment_version(self.user_ids)
    end
  end
   
  def update_group_name_of_pages
    Page.connection.execute "UPDATE pages SET `group_name` = '#{self.name}' WHERE pages.group_id = #{self.id}"
    Page.connection.execute "UPDATE pages SET `owner_name` = '#{self.name}' WHERE pages.owner_id = #{self.id} AND pages.owner_type = 'Group'"
  end
    
end
