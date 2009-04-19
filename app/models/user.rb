class User < ActiveRecord::Base

  # core user extentions
  include UserExtension::Cache      # should come first
  include UserExtension::Socialize  # user <--> user
  include UserExtension::Organize   # user <--> groups
  include UserExtension::Sharing    # user <--> pages
  include UserExtension::Tags       # user <--> tags  
  include UserExtension::AuthenticatedUser

  ##
  ## VALIDATIONS
  ##

  include CrabgrassDispatcher::Validations
  validates_handle :login

  validates_presence_of :email if Conf.require_user_email
  # ^^ TODO: make this site specific
  
  validates_as_email :email
  before_validation 'self.email = nil if email.empty?'
  # ^^ makes the validation succeed if email == ''

  ##
  ## NAMED SCOPES
  ##

  named_scope :recent, :order => 'users.created_at DESC', :conditions => ["users.created_at > ?", RECENT_SINCE_TIME]

  # alphabetized and (optional) limited to +letter+
  named_scope :alphabetized, lambda {|letter|
    opts = {
      :order => 'login ASC'
    }
    if letter == '#'
      opts[:conditions] = ['login REGEXP ?', "^[^a-z]"]
    elsif not letter.blank?
      opts[:conditions] = ['login LIKE ?', "#{letter}%"]
    end

    opts
  }

  # select only logins
  named_scope :logins_only, :select => 'login'

  
  ##
  ## USER IDENTITY
  ##

  belongs_to :avatar
  has_many :profiles, :as => 'entity', :dependent => :destroy, :extend => ProfileMethods

  # this is a hack to get 'has_many :profiles' to polymorph
  # on User instead of AuthenticatedUser
  #def self.base_class; User; end
  
  validates_format_of :login, :with => /^[a-z0-9]+([-_\.]?[a-z0-9]+){1,17}$/
  before_validation :clean_names
  
  def clean_names
    write_attribute(:login, (read_attribute(:login)||'').downcase)
    
    t_name = read_attribute(:display_name)
    if t_name
      write_attribute(:display_name, t_name.gsub(/[&<>]/,''))
    end
  end

  after_save :update_name
  def update_name
    if login_changed?
      Page.connection.execute "UPDATE pages SET `updated_by_login` = '#{self.login}' WHERE pages.updated_by_id = #{self.id}"
      Page.connection.execute "UPDATE pages SET `created_by_login` = '#{self.login}' WHERE pages.created_by_id = #{self.id}"
    end
  end

  after_destroy :kill_avatar
  def kill_avatar
    avatar.destroy if avatar
  end
  
  # the user's custom display name, could be anything.
  def display_name
    read_attribute('display_name').any? ? read_attribute('display_name') : login
  end
  
  # the user's handle, in same namespace as group name,
  # must be url safe.
  def name; login; end
  
  # displays both display_name and name
  def both_names
    if read_attribute('display_name').any? and read_attribute('display_name') != name
      '%s (%s)' % [display_name,name]
    else
      name
    end
  end
  alias :to_s :both_names   # used for indexing

  def cut_name
    name[0..20]
  end
    
  def to_param
    return login
  end

  def banner_style
    #@style ||= Style.new(:color => "#E2F0C0", :background_color => "#6E901B")
    @style ||= Style.new(:color => "#eef", :background_color => "#1B5790")
  end
    
  def online?
    last_seen_at > 10.minutes.ago if last_seen_at
  end
  
  def time_zone
    read_attribute(:time_zone) || Time.zone_default
  end

  ##
  ## USER SETTINGS
  ##

  has_one :setting, :class_name => 'UserSetting', :dependent => :destroy

  # allow us to call user.setting.x even if user.setting is nil
  def setting_with_safety; setting_without_safety or UserSetting.new; end
  alias_method_chain :setting, :safety

  def update_or_create_setting(attrs)
    if setting.id
      setting.update_attributes(attrs)
    else
      create_setting(attrs)
    end
  end


  # returns true if the user wants to receive
  # and email when someone sends them a page notification
  # message.
  def wants_notification_email?
    self.email.any?
  end

  ##
  ## ASSOCIATED DATA
  ## 

  has_many :task_participations, :dependent => :destroy
  has_many :tasks, :through => :task_participations do
    def pending
      self.find(:all, :conditions => 'assigned == TRUE AND completed_at IS NULL')
    end
    def completed
      self.find(:all, :conditions => 'completed_at IS NOT NULL')
    end
    def priority
      self.find(:all, :conditions => ['due_at <= ? AND completed_at IS NULL', 1.week.from_now])
    end
  end

  after_destroy :destroy_requests
  def destroy_requests
    Request.destroy_for_user(self)
  end

  ##
  ## PERMISSIONS
  ##

  # Returns true if self has the specified level of access on the protected thing.
  # Thing may be anything that defines the method:
  #
  #    has_access!(access_sym, user)
  #
  # Currently, this includes Page and Group.
  #
  # this method gets called a lot (ie current_user.may?(:admin,@page)) so 
  # we in-memory cache the result.
  #
  def may?(perm, protected_thing)
    begin
      may!(perm, protected_thing)
    rescue PermissionDenied
      false
    end
  end
  
  def may!(perm, protected_thing)
    return true if protected_thing.new_record?
    @access ||= {}
    (@access["#{protected_thing.to_s}"] ||= {})[perm] ||= protected_thing.has_access!(perm,self)
  end

  # zeros out the in-memory page access cache. generally, this is called for
  # you, but must be called manually in the case where page access was via a
  # group and that group loses page access.
  def clear_access_cache
    @access = nil
  end

  # as special call used in special places: This should only be called if you
  # know for sure that you can't use user.may?(:admin,thing)
  def may_admin?(thing)
    begin
      thing.has_access!(:admin,self)
    rescue PermissionDenied
      false
    end
  end

  # TODO: this does not belong here, should be in the mod, but it was not working
  # there.
  include UserExtension::SuperAdmin rescue NameError
end
