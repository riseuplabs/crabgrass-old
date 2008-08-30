=begin

PAGE.RB

A Page is the main content class. All actual content is a subclass of this class.

denormalization:
all the relationship between a page and its groups is stored in the group_participations table. however, we denormalize some of it: group_name and group_id are used to store the info for the 'primary group'. what does this mean? the primary group is what is show when listing pages and it is the default group when linking from a wiki.

=end

class Page < ActiveRecord::Base
  extend PathFinder::FindByPath
  include PageExtension::Users
  include PageExtension::Groups
  include PageExtension::Create
  include PageExtension::Subclass

  acts_as_taggable_on :tags

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
  
  ## update attachment permissions
  after_save :update_access
  def update_access
    assets.each { |asset| asset.update_access }
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

    self.page_index.title      = self.title.capitalize
    self.page_index.resolved   = self.resolved
    self.page_index.page_created_at = self.created_at
    self.page_index.page_created_by_id = self.created_by_id
    self.page_index.page_created_by_login = self.created_by_login
    self.page_index.page_updated_at = self.updated_at
    self.page_index.page_updated_by_login = self.updated_by_login
    self.page_index.starts_at  = self.starts_at
    self.page_index.group_name      = self.group_name

    
    # previously, we would pass this indexing fuction off to page.data,
    # but i think it is classier to have the page subclasses override the index_data method
    # page_index.body = (data and data.index)
    self.page_index.body = index_frontmatter + index_data + index_discussion
    self.page_index.type = type
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
    return "" unless self.discussion
    self.discussion.posts.collect {|p| p.user and p.body ? "#{p.user.login}: #{p.body} /" : ""}.join(' ')
  end

  def index_frontmatter
    return "#{self.name}\n#{self.title}\n#{self.summary}"
  end


=begin  
  # this indexing is really slow, perhaps due to the join with page_index
  # let's index that directly, as it is much faster
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
#      indexes discussion.posts.body, :as => :comments
      
      
      indexes :resolved
      
      has :created_at
      has :created_by_id
      has :updated_at
      has :updated_by_id
      has :group_id
      has :starts_at
    
#      set_property :delta => true
# TODO: figure out if this exception handling is slowing down saving or indexing
#    rescue
#      RAILS_DEFAULT_LOGGER.warn "failed to index page #{self.id} for sphinx search"
    end
  end
=end

end
