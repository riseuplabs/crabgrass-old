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

See sites.yml for example of the stuff that gets serializes to :translators,
:available_page_types and :evil

=end
class Site < ActiveRecord::Base

  serialize :translators, Array
  serialize :available_page_types, Array
  serialize :evil, Hash

  #include SiteProfileMethods
  # the default site when no others match
  # cattr_accessor :default
  # a hash of all the sites
  # cattr_accessor :sites
  cattr_accessor :current

  def self.sites
    Site.find :all
  end

  def self.default
    if @default_site.nil?
      @default_site = Site.find :first, :conditions => ["sites.default = '?'", true]
      @default_site ||= Site.find :first
    end
    @default_site
  end

  # def self.current
  #   # this will become dynamic
  #   self.default
  # end
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
end
