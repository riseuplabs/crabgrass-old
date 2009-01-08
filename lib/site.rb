require 'site_profile_methods'

class Site
  
  #include SiteProfileMethods

  # once sites are stored in the database, these accessors will go away:
  attr_accessor :name
  attr_accessor :domain
  attr_accessor :email_sender
  attr_accessor :secret
  attr_accessor :pagination_size
  attr_accessor :super_admin_group_id
  attr_accessor :translators
  attr_accessor :translation_group
  attr_accessor :default_language
  attr_accessor :evil
  attr_writer   :available_page_types
  attr_accessor :tracking
  #attr_accessor :profiles

  # the default site when no others match
  cattr_accessor :default
  # a hash of all the sites
  cattr_accessor :sites

  def initialize(hsh)
    hsh.each do |key,value|
      method = key.to_s + '='
      self.send(method,value) if self.respond_to?(method)
    end
    #setup_profile_methods
  end

  def available_page_types
    @available_page_types ||= PAGES.collect.sort_by{|p|p[1].order}.collect{|p|
      p[1].class_name unless p[1].internal
    }.compact
  end

  def self.load_from_file(filename)
    self.sites = {}
    site_configs = YAML.load_file(filename)
    site_configs.each do |site_match_expr, config|
      self.sites[site_match_expr] = Site.new(config)
    end
    self.default = self.sites['default']
  end

  def self.find_by_domain()
    self.default
  end

end

