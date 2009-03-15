# require 'site_profile_methods'
=begin
A definition of a site.

In crabgrass, 'sites' are several social networks hosted on the same rails instance sharing a single
data store. Different sites are identified by different domain names, but all of the domains point to
a single IP address. Each site can have a unique visual appearance, it can limit the tools
available to its users, but all of their code and data is shared (of course, it's possible to hide data between sides)

create_table "sites", :force => true do |t|
  t.string  "name"
  t.string  "domain"
  t.string  "email_sender"
  t.integer "pagination_size",      :limit => 11
  t.integer "super_admin_group_id", :limit => 11
  t.text    "translators"
  t.string  "translation_group"
  t.string  "default_language"
  t.text    "available_page_types"
  t.text    "evil"
  t.boolean "tracking"
  t.boolean "default",                            :default => false
end

See sites.yml for example of the stuff that gets serialized to :translators,
:available_page_types and :evil

=end
class Site < ActiveRecord::Base

  
# We want a network having several sites.  
#  That's why we change the put the network_id into the site
#  has_one :network
  belongs_to :network
  
  serialize :translators, Array
  serialize :available_page_types, Array
  serialize :evil, Hash

  #include SiteProfileMethods

  cattr_accessor :current

  def self.sites
    Site.find :all
  end

  before_save :ensure_network
  
  def ensure_network
    self.network = Network.first
  end
  
  
  
  def self.default
    @default_site ||= 
      Site.find(:first, :conditions => ["sites.default = '?'", true]) ||
      Site.find(:first) ||
      Site.new(:name => 'unknown')
  end

  # def stylesheet_render_options(path)
  #   {:text => "body {background-color: purple;} \n /* #{path.inspect} */"}
  # end

######### DEFAULT SERIALIZED VALUES ###########
  # :cal-seq:
  #   site.translators => ["gerrard", "jim", "purple"]
  def translators
    read_attribute(:translators) || write_attribute(:translators, [])
  end

  # :cal-seq:
  #   site.available_page_types => ["Wiki", "Article", "Gallery", ...]
  def available_page_types
    read_attribute(:available_page_types) || write_attribute(:available_page_types, [])
  end

  # :cal-seq:
  #   site.evil => {}
  def evil
    read_attribute(:evil) || write_attribute(:evil, {})
  end

  
  
  
# 
# RELATIONS
#  
  
  # [TODO] a user can be autoregistered in site.network
  # def add_user
  # end
  
  # returns true if the thing is part of the network
  def has? arg
    self.site.has?(arg)
  end
  
  
  # gets all the users in the site
  def users
    self.network.users
  end
  
  # gets all the user ids in the site #TODO cache this
  def user_ids
    self.network.user_ids
  end
  
  # gets all the pages for all the groups in the site
  def pages
    pages = []
    self.network.pages.each do |page|
      pages <<  page unless pages.include?(page)
    end
    self.network.users.each do |user|
      user.pages.each do |page|
        pages << page unless pages.include?(page)
      end
    end
    pages
  end
 
  
  # gets all the groups in the site's network
  def groups
    self.network.groups
  end
  
  # gets all the ids of all the groups in the site
  def group_ids
    self.network.group_ids
  end
  
  # gets the intersection of the groups visible for user and the site's groups
  def groups_for_user(user)
    Group.visible_by(user) &  groups
  end
  
  # gets the intersection of the user's contacts with the site's users
  def friends_for_user(user)
    user.contacts & users
  end
  
  # gets the intersection of the user's peers with the site's users
  def peers_for_user(user)
    user.pears & users
  end
  
  # gets the intersection of the user's pages with the site's pages
  def pages_for_user(user)
    user.pages & pages
  end
  
end
