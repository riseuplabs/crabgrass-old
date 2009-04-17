#
# This class provides access to config/crabgrass.RAILS_ENV.yml.
# 
# The variables defined there are available as Config.varname
#
class Conf

  # default site options
  cattr_accessor :name
  cattr_accessor :pagination_size
  cattr_accessor :default_language
  cattr_accessor :email_sender
  cattr_accessor :super_admin_group
  cattr_accessor :available_page_types
  cattr_accessor :tracking
  cattr_accessor :evil

  # should be in site, but are not.
  cattr_accessor :enforce_ssl
  cattr_accessor :show_exceptions
  cattr_accessor :require_user_email

  # are in site, but I think they should be global
  cattr_accessor :translators
  cattr_accessor :translation_group

  # global instance options
  cattr_accessor :enabled_mods
  cattr_accessor :enabled_tools
  cattr_accessor :email
  cattr_accessor :sites
  cattr_accessor :secret
  

  # set automatically
  cattr_accessor :super_admin_group_id

  def self.load_defaults
    self.name              = 'crabgrass'
    self.pagination_size   = 30
    self.default_language  = 'en_US'
    self.email_sender      = 'robot@$current_host'
    self.tracking          = false
    self.evil              = {}
    self.super_admin_group = nil
    self.available_page_types = []

    # should be in site, but are not.
    self.enforce_ssl     = false
    self.show_exceptions = true
    
    # instance configuration
    self.enabled_mods  = []
    self.enabled_tools = []
    self.email         = nil
    self.sites         = nil
    self.secret        = nil
  end

  def self.load(filename)
    self.load_defaults
    filename = [RAILS_ROOT, 'config', filename].join('/')
    hsh = YAML.load_file(filename)
    hsh.each do |key, value|
      method = key.to_s + '='
      if self.respond_to?(method)
        self.send(method,value) if value
      else
        puts "configuration error: unknown option '%s'" % key
      end
    end
  end 

  #@@settings = {}
  #def self.method_missing(name, *args)
  #  key = name.to_s.gsub(/[\?=]$/,'')
  #  if name.to_s.ends_with?('=')
  #    @@settings[key] = *args     # assignment
  #  else
  #    @@settings[key]             # retrieval
  #  end
  #end

end


