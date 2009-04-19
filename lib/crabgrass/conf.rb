#
# This class provides access to config/crabgrass.RAILS_ENV.yml.
# 
# The variables defined there are available as Config.varname
#
class Conf
  # Site attributes that can only be specified in crabgrass.*.yml.
  cattr_accessor :name
  cattr_accessor :admin_group

  # Default values for site objects. If a site does not have
  # a value defined for one of these, we use the default in 
  # the config file, or defined here. 
  cattr_accessor :title
  cattr_accessor :pagination_size
  cattr_accessor :default_language
  cattr_accessor :email_sender
  cattr_accessor :available_page_types
  cattr_accessor :tracking
  cattr_accessor :evil
  cattr_accessor :enforce_ssl
  cattr_accessor :show_exceptions
  cattr_accessor :require_user_email
  cattr_accessor :domain

  # are in site, but I think they should be global
  cattr_accessor :translators
  cattr_accessor :translation_group

  # global instance options
  cattr_accessor :enabled_mods
  cattr_accessor :enabled_tools
  cattr_accessor :enabled_languages
  cattr_accessor :email
  cattr_accessor :sites
  cattr_accessor :secret
  
  # set automatically from site.admin_group
  cattr_accessor :super_admin_group_id

  # set in environments/*.rb as semi-hardcoded options
  cattr_accessor :ignore_sass_file_timestamps

  # used for error reporting
  cattr_accessor :configuration_filename

  def self.load_defaults
    self.name                 = 'default'
    self.super_admin_group_id = nil

    # site defaults
    self.title             = 'crabgrass'
    self.pagination_size   = 30
    self.default_language  = 'en_US'
    self.email_sender      = 'robot@$current_host'
    self.tracking          = false
    self.evil              = {}
    self.available_page_types = []
    self.enforce_ssl       = false
    self.show_exceptions   = true
    self.domain            = 'localhost'

    # instance configuration
    self.enabled_mods  = []
    self.enabled_tools = []
    self.enabled_languages = []
    self.email         = nil
    self.sites         = []
    self.secret        = nil
  end

  def self.load(filename)
    self.load_defaults
    self.configuration_filename = [RAILS_ROOT, 'config', filename].join('/')
    hsh = YAML.load_file(configuration_filename) || {}
    hsh.each do |key, value|
      method = key.to_s + '='
      if self.respond_to?(method)
        self.send(method,value) if value
      else
        puts "ERROR (%s): unknown option '%s'" % [configuration_filename,key]
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

  # enabled a tool plugin or a mod plugin if explicitly enabled
  def self.mod_enabled?(mod_name)
    self.enabled_mods.include?(mod_name)
  end

  # also allow by default if empty 
  def self.tool_enabled?(tool_name)
    self.enabled_tools.empty? or self.enabled_tools.include?(tool_name)
  end

end


