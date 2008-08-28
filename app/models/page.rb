
# notes
# all the relationship between a page and its groups is stored in the group_participations
# table. however, we denormalize some of it: group_name and group_id are used to store
# the info for the 'primary group'. what does this mean? the primary group is what is 
# show when listing pages and it is the default group when linking from a wiki. 
# 

class Page < ActiveRecord::Base
  extend PathFinder::FindByPath
  
  acts_as_taggable_on :tags
  def set_tag_list(str)
    self.tag_list = (str||'').gsub(/[ \t\n]/, ',')
  end

  #######################################################################
  ## PAGE NAMING
  
  validates_format_of  :name, :with => /^$|^[a-z0-9]+([-_]*[a-z0-9]+){1,39}$/

  def validate
    if (name_changed? or group_id_changed?) and name_taken?
      errors.add 'name', 'is already taken'
    end
  end

  def name_url
    name.any? ? name : friendly_url
  end
  
  def friendly_url
    s = title.nameize
    s = s[0..40].sub(/-([^-])*$/,'') if s.length > 42     # limit name length, and remove any half-cut trailing word
    "#{s}+#{id}"
  end

  # using only knowledge of this page, returns
  # best guess uri string, sans protocol/host/port.
  # ie /rainbows/what-a-fine-page+5234
  def uri
   return [group_name, name_url].path if group_name
   return [created_by_login, friendly_url].path if created_by_login
   return ['page', friendly_url].path
  end

  # returns true if self's unique page name is already in use.
  # what pages are in the namespace? all pages connected to all
  # groups connected to this page (include the group's committees too).
  def name_taken?
    return false unless self.name.any?
    p = Page.find(:first,
      :conditions => ['pages.name = ? and group_participations.group_id IN (?)', self.name, self.namespace_group_ids],
      :include => :group_participations
    )
    return false if p.nil?
    return self != p
  end

  #######################################################################
  ## RELATIONSHIP TO PAGE DATA
  
  belongs_to :data, :polymorphic => true, :dependent => :destroy
  has_one :discussion, :dependent => :destroy
  has_many :assets, :dependent => :destroy
      
  validates_presence_of :title
  validates_associated :data
  validates_associated :discussion

  def unresolve
    resolve(false)
  end
  def resolve(value=true)
    user_participations.each do |up|
      up.resolved = value
      up.save
    end
    self.resolved=value
    save
  end  

  def build_post(post,user)
    # this looks like overkill, but it seems to be needed
    # in order to build the post in memory and have it saved when
    # (possibly new) pages is saved
    self.discussion ||= Discussion.new
    self.discussion.page = self
    if post.instance_of? String
      post = Post.new(:body => post)
    end
    self.discussion.posts << post
    post.discussion = self.discussion
    post.user = user
    return post
  end
  
  ## update ASSET permissions
  after_save :update_access
  def update_access
    assets.each { |asset| asset.update_access }
  end
  
  #######################################################################
  ## RELATIONSHIP TO USERS

  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
  belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
  has_many :user_participations, :dependent => :destroy
  has_many :users, :through => :user_participations do
    def with_access
      find(:all, :conditions => 'access IS NOT NULL')
    end
    def participated
      find(:all, :conditions => 'changed_at IS NOT NULL')
    end
  end

  # like users.with_access, but uses already included data
  def users_with_access
    user_participations.collect{|part| part.user if part.access }.compact
  end
  
  # like users.participated, but uses already included data
  def contributors
    user_participations.collect{|part| part.user if part.changed_at }.compact
  end
  
  # like user_participations.find_by_user_id, but uses already included data
  def participation_for_user(user) 
    user_participations.detect{|p| p.user_id==user.id }
  end

  # A list of the user participations, with the following properties:
  # * sorted first by access level
  # * sorted second by username
  # * limited to users who have access OR changed_at set
  def sorted_user_participations
    self.users # make sure all users are fetched
    user_participations.select {|upart|
      upart.access or upart.changed_at
    }.sort {|a,b|
      if a.access == b.access
        a.user.login <=> b.user.login
      else
        (a.access||100) <=> (b.access||100)
      end
    }
  end

  # used for ferret index
  def user_ids
    user_participations.collect{|upart|upart.user_id}
  end

  before_create :set_user
  def set_user
    if User.current or self.created_by
      self.created_by ||= User.current
      self.created_by_login = self.created_by.login
      self.updated_by       = self.created_by
      self.updated_by_login = self.created_by.login
    end
    true
  end

  #######################################################################
  ## RELATIONSHIP TO GROUPS
  
  has_many :group_participations, :dependent => :destroy
  has_many :groups, :through => :group_participations
  belongs_to :group # the main group
  
  has_many :namespace_groups, :class_name => 'Group', :finder_sql => 'SELECT groups.* FROM groups WHERE groups.id IN (#{namespace_group_ids_sql})'
  
  # When getting a list of ids of groups for this page,
  # we use group_participations. This way, we will have
  # current data even if a group is added and the page
  # has not yet been saved.
  # used extensively, and by ferret.
  def group_ids
    group_participations.collect{|gpart|gpart.group_id}
  end
  
  # returns an array of group ids that compose this page's namespace
  # includes direct groups and all the relatives of the direct groups.
  def namespace_group_ids
    Group.namespace_ids(group_ids)
  end
  def namespace_group_ids_sql
    namespace_group_ids.any? ? namespace_group_ids.join(',') : 'NULL'
  end

  # takes an array of group ids, return all the matching group participations
  # this is called a lot, since it is used to determine permission for the page
  def participation_for_groups(group_ids) 
    group_participations.collect do |gpart|
      gpart if group_ids.include? gpart.group_id
    end.compact
  end
  def participation_for_group(group)
    group_participations.detect{|gpart| gpart.group_id == group.id}
  end

  # a list of the group participation objects, but sorted
  # by access (higher number is less access permissions)
  def sorted_group_participations
    group_participations.sort do |a,b|
      (a.access||100) <=> (b.access||100)
    end
  end

  #######################################################################
  ## RELATIONSHIP TO OTHER PAGES
  
  # reciprocal links between pages
  has_and_belongs_to_many :links,
    :class_name => "Page",
    :join_table => "links",
    :association_foreign_key => "other_page_id",
    :foreign_key => "page_id",
    :uniq => true,
    :after_add => :reciprocate_add,
    :after_remove => :reciprocate_remove
  def reciprocate_add(other_page)
    other_page.links << self unless other_page.links.include?(self)
  end
  def reciprocate_remove(other_page)
    other_page.links.delete(self) rescue nil
  end
  def add_link(page)
    links << page unless links.include?(page)
  end
   
 
  #######################################################################
  ## RELATIONSHIP TO ENTITIES
    
  # add a group or user participation to this page
  def add(entity, attributes={})
    attributes[:access] = ACCESS[attributes[:access]] if attributes[:access]
    if entity.is_a? Enumerable
      entity.each do |e|
        e.add_page(self,attributes)
      end
    else
      entity.add_page(self,attributes)
    end
    self
  end
      
  # remove a group or user participation from this page
  def remove(entity)    
    if entity.is_a? Enumerable
      entity.each do |e|
        e.remove_page(self)
      end
    else
      entity.remove_page(self)
    end
    entity
  end

  
  #######################################################################
  ## SUPPORT FOR PAGE SUBCLASSING

  # to be set by subclasses (ie tools)
  class_attribute :controller, :model, :icon, :internal?,
    :class_description, :class_display_name, :class_group

  # lets us convert from a url pretty name to the actual class.
  def self.display_name_to_class(display_name)
    dn = display_name.nameize
    (PAGES.detect{|t|t[1].class_display_name.nameize == dn if t[1].class_display_name} || [])[1]
  end 
  # return an array of page classes that are members of class_group
  def self.class_group_to_class_names(class_group)
    PAGES.collect{|t|t[1].to_s if t[1].class_group == class_group and t[1].class_group}.compact
  end 
  # convert from a string representation of a class to the real thing (actually, a proxy)
  def self.class_name_to_class(class_name)
    (PAGES.detect{|t|t[1].class_name == class_name or t[1].class_name == "#{class_name}Page" } || [])[1]
  end

  def self.class_definition
    PAGES[self.name] || PageClassProxy.new
  end
  def class_definition
    PAGES[self.class.name] || PageClassProxy.new
  end
  def self.icon
    class_definition.icon
  end
  def icon
    class_definition.icon
  end
  def self.controller
    class_definition.controller
  end
  def controller
    class_definition.controller
  end
  def controller_class_name
    class_definition.controller_class_name
  end
  def self.class_display_name
    class_definition.class_display_name
  end
  def self.class_description
    class_definition.class_description
  end

  #######################################################################
  ## DENORMALIZATION

  before_save :denormalize
  def denormalize
    # denormalize hack follows:
    if group_participations.any?
      group = group_participations.first.group
      self.group_name = group.name
      self.group_id = group.id
    end
    if updated_by_id_changed?
      self.updated_by_login = (updated_by.login if updated_by)
    end
    true
  end
  
  # used to mark stuff that has been changed.
  # so that we know we need to update other stuff when saving.
  def dirty(what)
    @dirty ||= {}
    @dirty[what] = true
  end
  def dirty?(what)
    @dirty ||= {}
    @dirty[what]
  end

  #######################################################################
  ## MISC. HELPERS

  # tmp in-memory storage used by views
  def flag
    @flags ||= {}
  end

  def self.make(function,options={})
    PageStork.send(function, options)
  end

  #####################################################################
  ## Things related to the page to index with sphinx
  has_one :page_index, :dependent => :destroy

### TODO: make sphinx code fail gracefully if searchd is not running  
  before_save :async_update_index
  
  def async_update_index
    return true unless ::BACKGROUND
    begin
      MiddleMan.worker(:indexing_worker).async_update_page_index(:arg => self.id)
    rescue BackgrounDRb::NoServerAvailable => err
      logger.error "Warning: #{err}; performing synchronous update of page index"
      update_index
    end
  end
  
  def update_index
    self.page_index ||= PageIndex.new
    # store text version of user_ids and group_ids for sql full text search
    # page_index.user_ids_str = "xx13xx xx21xx" # or something, each word needs to be at least 4 chars (?)
    # page_index.group_ids_str = "xx13xx xx21xx" # or something, each word needs to be at least 4 chars (?)
    
    # previously, we would pass this indexing fuction off to page.data,
    # but i think it is classier to have the page subclasses override the index_data method
    # page_index.body = (data and data.index)
    self.page_index.body = index_data + index_discussion
    self.page_index.class_display_name = class_display_name
    self.page_index.tags = tag_list.join(', ')

    # the page_index table has a column of text describing what entities have
    # access to this page.  in the future, we might want several columns, for
    # full access, edit access, and comment access.
    self.page_index.entities = []
    self.page_index.entities << "public" if public?
    self.page_index.entities += group_ids.collect { |id| "group_#{id}" } if group_ids
    self.page_index.entities += user_ids.collect { |id| "user_#{id}"  }  if user_ids
    self.page_index.entities = self.page_index.entities.join(" ")
    
    self.page_index.save!
  end

  # subclasses should override this method as appropriate,
  # for example WikiPage will return wiki.body,
  # and TaskListPage will merge all of the tasks associated with it.
  # Maybe AssetPage will extract the text of a word document
  def index_data    
    ""
  end
  
  def index_discussion
    return "" unless discussion
    discussion.posts.collect {|p| p.user and p.body ? "#{p.user.login}: #{p.body} /" : ""}.join(' ')
  end
  
  define_index do
    begin
      indexes :name
      indexes :title, :sortable => true
      indexes :summary
 
      indexes page_index.body, :as => :body
      indexes page_index.class_display_name, :as => :class_display_name, :sortable => true
      indexes page_index.tags, :as => :tags
      indexes page_index.entities, :as => :entities

      # indexing is really slow on we.riseup
      # is this slowing down the indexing?
      indexes discussion.posts.body, :as => :comments
      
      
      indexes :resolved
      
      has :created_at
      has :created_by_id
      has :updated_at
      has :updated_by_id
      has :group_id
      has :starts_at
    
      set_property :delta => true
# TODO: figure out if this exception handling is slowing down saving or indexing
#    rescue
#      RAILS_DEFAULT_LOGGER.warn "failed to index page #{self.id} for sphinx search"
    end
  end

end
