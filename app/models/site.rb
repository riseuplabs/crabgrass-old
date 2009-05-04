=begin

A definition of a site.

In crabgrass, 'sites' are several social networks hosted on the same rails
instance sharing a single data store. Different sites are identified by
different domain names, but all of the domains point to a single IP address.
Each site can have a unique visual appearance, it can limit the tools available
to its users, but all of their code and data is shared (of course, it's possible
to hide data between sides)

  create_table "sites", :force => true do |t|
    t.string  "name"
    t.string  "domain"
    t.string  "email_sender"
    t.integer "pagination_size",      :limit => 11
    t.integer "super_admin_group_id", :limit => 11
    t.integer "council_id",           :limit => 11
    t.text    "translators"
    t.string  "translation_group"
    t.string  "default_language"
    t.text    "available_page_types"
    t.text    "evil"
    t.boolean "tracking"
    t.boolean "default",                            :default => false
    t.integer "network_id",           :limit => 11
    t.integer "custom_appearance_id", :limit => 11
    t.boolean "has_networks",                       :default => true
    t.string  "signup_redirect_url"
    t.string  "login_redirect_url"
    t.string  "title"
    t.boolean "enforce_ssl"
    t.boolean "show_exceptions"
    t.boolean "require_user_email"
  end

end

Example data for serialized fields:

  translators => ['blue', 'green', 'red']

  available_page_types => ['Discussion', 'Wiki', 'RateMany']

  evil => {"google_analytics"=>{"https"=>false, "enabled"=>false, "site_id"=>"UA-XXXXXX-X"}}

=end

class Site < ActiveRecord::Base
  belongs_to :network
  belongs_to :custom_appearance, :dependent => :destroy
  belongs_to :council, :class_name => 'Group'

  serialize :translators, Array
  serialize :available_page_types, Array
  serialize :evil, Hash
  
  serialize_default :featured_fields, {}

  # this is evil, but used by gibberish for site specific
  # override ability.
  cattr_accessor :current
  
  # FEATURED FIELDS
  #
  # Every site can enable single fields as featured fields
  #
  # They can have different options (this is to be extended)
  # - required : true|false this field will be used in validations and forms to be required
  # - show : true|false this field is enabled to be shown in a featured position
  #
  # show's default
  serialize :featured_fields, Hash
  serialize_default :featured_fields, {}
  after_save :update_featured_fields


  # we need to store any data, that a site's admin can set to
  # be a featured field in the user
  # We use User.update_featured_fields for that
  # TODO find a more general solution if needed
  # In the moment it's bound to the featured-fields functionality
  # that's boring. :)
  def update_featured_fields_as_context(item,data)
    items = self.users if(item == :user || item == nil)
    if items
      items.each do |item|
        item.update_featured_fields(data) if item.respond_to?(:update_featured_fields)
      end
    end
  end

  # calls the related model to update its featured fields
  def update_featured_fields
    data = featured_fields.keys
    update_featured_fields_as_context(:user,data)
  end

  # sets the featured fields
  # NOTE: normally use this method!
  #
  # takes as parameter:
  # {:fieldname => {:required => false, :show => true}
  #
  def set_featured_fields data
    default_data = { :required => false, :show => true}
    data.each do |field,options|
      options=default_data.merge(options)
      featured_fields[field] = options
    end
    save
  end

  # returns the featured fields for the user that correspond to the (current) site configuration
  def get_featured_fields_for_user(user)
    fields = { }
    # note, we give nil here to demonstrate, that also the current site or a group
    # could be given as context to separate cached data
    user.featured_fields_for_context(nil).each do |field,value|
      fields[field] = value if (self.featured_fields[field] && self.featured_fields[field][:show])
    end
    return fields
  end


  
#
# FEATURED FIELDS
#  
# Every site can enable single fields as featured fields
#
# They can have different options (this is to be extended)
# - required : true|false this field will be used in validations and forms to be required
# - show : true|false this field is enabled to be shown in a featured position
#
# show's default
  serialize :featured_fields, Hash
  serialize_default :featured_fields, {}
  after_save :update_featured_fields
  
  
# we need to store any data, that a site's admin can set to
# be a featured field in the user
# We use User.update_featured_fields for that
# TODO find a more general solution if needed
# In the moment it's bound to the featured-fields functionality
# that's boring. :)
  def update_featured_fields_as_context(item,data)
    items = self.users if(item == :user || item == nil)
    if items
      items.each do |item|
        item.update_featured_fields(data) if item.respond_to?(:update_featured_fields)
      end
    end
  end
  
  # calls the related model to update its featured fields
  def update_featured_fields
    data = featured_fields.keys
    update_featured_fields_as_context(:user,data)
  end
  
  # sets the featured fields
  # NOTE: normally use this method!
  #
  # takes as parameter:
  # {:fieldname => {:required => false, :show => true}
  # 
  def set_featured_fields data
    default_data = { :required => false, :show => true}
    data.each do |field,options|
      options=default_data.merge(options)
      featured_fields[field] = options
    end
    save
  end
  
  # returns the featured fields for the user that correspond to the (current) site configuration
  def get_featured_fields_for_user(user)
    fields = { }
    # note, we give nil here to demonstrate, that also the current site or a group
    # could be given as context to separate cached data
    user.featured_fields_for_context(nil).each do |field,value|
      fields[field] = value if (self.featured_fields[field] && self.featured_fields[field][:show])
    end
    return fields
  end
  
  ##
  ## FINDERS
  ##

  named_scope :for_domain, lambda {|domain|
    {:conditions => ['sites.domain = ? AND sites.id IN (?)', domain, Conf.enabled_site_ids]}
  }

  def self.default
    @default_site ||= Site.find(:first, :conditions => ["sites.default = ? AND sites.id in (?)", true, Conf.enabled_site_ids]) || Site.new()
  end

  # def stylesheet_render_options(path)
  #   {:text => "body {background-color: purple;} \n /* #{path.inspect} */"}
  # end

  # returns true if this site should display content limited to this site only.
  # the default for sites is to always display just the data for the site.
  # however, some sites may be umbrella sites that have access to everything. 
  # for now, if self is not actually a site in the database then we treat it
  # as an umbrella site.
  def limited?
    not self.id.nil?
  end

  ##
  ## CONFIGURATION & DEFAULT VALUES
  ##

  # For the attributes, use the site's value first, if possible, and
  # fall back to Conf if the value is not set. We can also proxy attributes
  # which do not actually exist in the sites table but which do exist in the
  # configuration file.
  #
  # These defaults are defined in lib/crabgrass/conf.rb (and are changed by
  # whatever crabgrass.*.yml gets loaded).
  def self.proxy_to_conf(*attributes)
    attributes.each do |attribute|
      define_method(attribute) { (value = read_attribute(attribute.to_s.sub(/\?$/,''))).nil? ? Conf.send(attribute) : value }
    end
  end

  proxy_to_conf :name, :title, :pagination_size, :default_language, :email_sender,
    :available_page_types, :tracking, :evil, :enforce_ssl, :show_exceptions,
    :require_user_email, :domain, :profiles, :profile_fields, :chat?

  def profile_field_enabled?(field)
    profile_fields.nil? or profile_fields.include?(field.to_s)
  end

  def profile_enabled?(profile)
    profiles.nil? or profiles.include?(profile.to_s)
  end

  ##
  ## RELATIONS
  ##

  # a user can be autoregistered in site.network
  def add_user!(user)
    self.network.add_user!(user) unless self.network.nil? or user.member_of?(self.network)
  end

  # returns true if the thing is part of the network
  def has? arg
    self.network.nil? ? true : self.network.has?(arg)
  end

  # gets all the users in the site
  def users
    self.network.nil? ? User.find(:all) : self.network.users
  end

  # gets all the user ids in the site #TODO cache this
  def user_ids
    self.network.nil? ?
      User.find(:all, :select => :id).collect{|user| user.id} :
      self.network.user_ids
  end

  
  # gets all the pages for all the groups in the site
  # this does not work. network.pages only contains
  # the pages that have a group_participation by the network itself.
  #def pages
  #  pages = []
  #  self.network.pages.each do |page|
  #    pages <<  page unless pages.include?(page)
  #  end
  #  self.network.users.each do |user|
  #    user.pages.each do |page|
  #      pages << page unless pages.include?(page)
  #    end
  #  end
  #  pages
  #end

  # gets all the groups in the site's network
  def groups
    self.network.nil? ?
      Group.find(:all) :
      self.network.groups
  end

  # gets all the ids of all the groups in the site
  def group_ids
    self.network.nil? ?
      Group.find(:all, :select => :id).collect{|group| group.id} :
      self.network.group_ids
  end

  ##
  ## CUSTOM STRINGS
  ##

  def string(symbol, language_code)
    nil
  end

  ##
  ## LOGGING IN 
  ##

  # Where does the user go when they login? Let the site decide.
  def login_redirect(user)
    if self.login_redirect_url
      self.login_redirect_url
    elsif self.network
      '/'
    else
      {:controller =>'/me/dashboard'}
     end
  end

  # if user has +access+ to site, return true.
  # otherwise, raise PermissionDenied
  def has_access!(access, user)
    if access == :admin and not self.council.nil?
      ok = user.member_of?(self.council)
    end
    ok or raise PermissionDenied.new
  end

  # TODO : find a place to define all the elements, a site's user can see
  #        (means: things, where we log, if he has already seen them)
  #
  
  # tells the site, that a user has seen something 
  #def seen_by_user(user,element)
  # membership = self.network.memberships.find_by_user_id(user.id)
  # membership.seen ||= []
  # membership.seen.push(element).uniq
  # membership.save
  #end
  
  # the user forgot, that he had seen this
  #def unsee(user,element)
  #  membership = self.network.memberships.find_by_user_id(user.id)
  #  membership.seen.delete(element)
  #end
  
  # tells us, that a user of this site has already seen this  
  #def seen_for_user?(user,element)
  #  membership = self.network.memberships.find_by_user_id(user.id)
  #  ( membership.seen && membership.seen.include?(element.to_s)) ? true : false
  #end
    
end
