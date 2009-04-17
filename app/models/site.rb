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

Example data for serialized fields:

  translators => ['blue', 'green', 'red']

  available_page_types => ['Discussion', 'Wiki', 'RateMany']

  evil => {"google_analytics"=>{"https"=>false, "enabled"=>false, "site_id"=>"UA-XXXXXX-X"}}

=end

class Site < ActiveRecord::Base

  belongs_to :network

  # associate with appearances
  belongs_to :custom_appearance

  serialize :translators, Array
  serialize :available_page_types, Array
  serialize :evil, Hash

  cattr_accessor :current

  def self.sites
    Site.find :all
  end

  def self.default
    @default_site ||=
      Site.find(:first, :conditions => ["sites.default = '?'", true]) ||
      Site.new() #:name => 'unknown', :available_page_types => PAGES.keys)
  end


  # def stylesheet_render_options(path)
  #   {:text => "body {background-color: purple;} \n /* #{path.inspect} */"}
  # end

  ##
  ## DEFAULT VALUES
  ##

  # for the attributes, use the site's value first, if possible, and
  # fall back to Conf if the value is not set. These defaults are defined in
  # lib/crabgrass/conf.rb
  def method_missing(method, *args)
    if Conf.respond_to?(method) and args.empty?
      super(method) || Conf.send(method)
    else
      super(method, *args)
    end
  end

  ## configuration options that should be in sites, but are still in global Conf
  def require_user_email; Conf.require_user_email; end
  def enforce_ssl; Conf.enforce_ssl; end
  def show_exception; Conf.show_exceptions; end


  ##
  ## RELATIONS
  ##

  # a user can be autoregistered in site.network
  def add_user!(user)
    self.network.add_user!(user) unless self.network.nil?
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

end
