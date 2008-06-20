class User < ActiveRecord::Base

  include AuthenticatedUser
  include CrabgrassDispatcher::Validations
  include SocialUser

  validates_handle :login
  
  #########################################################    
  # my identity

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

  def cut_name
    name[0..20]
  end
    
  def to_param
    return login
  end

  def banner_style
    @style ||= Style.new(:color => "#E2F0C0", :background_color => "#6E901B")
  end
    
  def online?
    last_seen_at > 10.minutes.ago if last_seen_at
  end
  
  def time_zone
    read_attribute(:time_zone) || DEFAULT_TZ
  end

  #########################################################    
  # my tasks

=begin
  has_and_belongs_to_many :tasks do
    def pending
      self.find(:all, :conditions => 'completed_at IS NULL')
    end
    def completed
      self.find(:all, :conditions => 'completed_at IS NOT NULL')
    end
    def priority
      self.find(:all, :conditions => ['due_at <= ? AND completed_at IS NULL', 1.week.from_now])
    end
  end
=end
  
end
