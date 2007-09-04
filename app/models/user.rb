
class User < SocialUser  

  acts_as_modified
  
  #########################################################    
  # my identity

  belongs_to :avatar

  validates_format_of :login, :with => /^[a-z0-9]+([-_\.]?[a-z0-9]+){1,17}$/
  validates_handle :login
  before_validation_on_create :clean_login
  
  def clean_login
    write_attribute(:login, (read_attribute(:login)||'').downcase)
  end

  after_save :update_name
  def update_name
    if login_modified?
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

  ############################################################################
  ## RELATIONSHIP TO PAGES
  
  has_many :participations, :class_name => 'UserParticipation', 
    :after_add => :update_tag_cache, :after_remove => :update_tag_cache
  has_many :pages, :through => :participations do
    def pending
      find(:all, :conditions => ['resolved = ?',false], :order => 'happens_at' )
    end
  end
  
  has_many :pages_created,
    :class_name => "Page", :foreign_key => :created_by_id 

  has_many :pages_updated, 
    :class_name => "Page", :foreign_key => :updated_by_id   

  def may?(perm, page)
    begin
      return may!(perm,page)
    rescue PermissionDenied
      return false
    end
  end
  
  # basic permissions:
  #   :view or :read -- user can see the page.
  #   :edit or :change -- user can participate.
  #   :admin -- user can destroy the page, change access.
  # conditional permissions:
  #   :comment -- sometimes viewers can comment and sometimes only participates can.
  #
  # this is still a basic stub.
  #
  # :view should only return true if the user has access to view the page
  # because of participation objects, NOT because the page is public.
  #
  def may!(perm, page)
    upart = page.participation_for_user(self)
    return true if upart
    gparts = page.participation_for_groups(all_group_ids)
    return true if gparts.any?
    raise PermissionDenied
  end
  
  ##
  ## makes self a participant of a page. 
  ## this method is not called directly. instead, page.add(user)
  ## should be used.
  ##
  def add_page(page, part_attrs)
    part_attrs = part_attrs.dup
    part_attrs[:notice] = [part_attrs[:notice]] if part_attrs[:notice]
    participation = page.participation_for_user(self)
    if participation
      self.update_participation(participation, part_attrs)
    else
      self.create_participation(page, part_attrs)
    end  
    page.changed :users
  end
  ## called only by add_page
  def update_participation(participation, part_attrs)
    if part_attrs[:notice]        
      part_attrs[:viewed] = false
      if participation.notice
        if repeat_notice?(participation.notice, part_attrs[:notice])
          part_attrs[:notice] = participation.notice # don't repeat
        else
          part_attrs[:notice] += participation.notice
        end
      end
    end
    participation.update_attributes(part_attrs)
  end
  ## called only by update_participation
  def repeat_notice?(current_notices, new_notice)
    new_notice = new_notice.first
    current_notices.detect do |notice|
      notice[:message] == new_notice[:message] and notice[:user_login] == new_notice[:user_login]
    end
  end
  ## called only by add_page
  def create_participation(page, part_attrs)
    # user_participations.build doesn't update the pages.users
    # until it is saved, so we use create instead
    page.user_participations.create(part_attrs.merge(
      :page_id => page.id, :user_id => id,
      :resolved => page.resolved?))
  end
  
  def remove_page(page)
    page.users.delete(self)
    page.changed :users
  end
  
  # should be called when a user visits a page
  # we only update user_participation if it already exists
  def viewed(page)
    part = page.participation_for_user(self)
    return unless part
    part.update_attributes(:viewed_at => Time.now, :notice => nil, :viewed => true)
  end
  
  # set resolved status vis-à-vis self.
  def resolved(page, resolved_flag)
    find_or_build_participation(page).update_attributes :resolved => resolved_flag
  end
  
  def find_or_build_participation(page)
    page.participation_for_user(self) || page.user_participations.build(:user_id => self.id) 
  end
  
  # should be called when a user writes to a page
  # or resolves a page.
  # options:
  #  - resolved: user's participation is resolved with this page
  #  - all_resolved: everyone's participation is resolved.
  #
  def updated(page, options={})
    # create self's participation if it does not exist
    find_or_build_participation(page)

    unless page.contributors.include?(self)
      page.contributors_count +=1
    end
     
    # update everyone's participation
    now = Time.now
    page.user_participations.each do |party|
      if party.user_id == self.id
        party.changed_at = now
        party.viewed_at = now
        party.viewed = true
        party.resolved = options[:resolved] || options[:all_resolved] || party.resolved?
      else
        party.resolved = options[:all_resolved] || party.resolved?
        party.viewed = false
      end
      party.save      
    end
    # this is unfortunate, because perhaps we have already just modified the page?
    page.resolved = options[:all_resolved] || page.resolved?
    page.updated_at = now
    page.updated_by = self
    page.changed :updated_by
    page.save
  end
    
end
