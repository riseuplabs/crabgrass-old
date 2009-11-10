#
# This class provides access to config/crabgrass.RAILS_ENV.yml.
#
# The variables defined there are available as Config.varname
#
class Conf

  ##
  ## CONSTANTS
  ##

  SIGNUP_MODE = Hash.new(0).merge({
    :default => 0, :closed => 1, :invite_only => 2, :verify_email => 3
  }).freeze

  TEXT_EDITOR = Hash.new(0).merge({
    :greencloth_only => 0,        :html_only => 1,
    :greencloth_preferred => 2,   :html_preferred => 3
  }).freeze

  ##
  ## CLASS ATTRIBUTES
  ## (these are ok, because they are shared among all sites)
  ##

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
  cattr_accessor :email_sender_name
  cattr_accessor :available_page_types
  cattr_accessor :tracking
  cattr_accessor :evil
  cattr_accessor :enforce_ssl
  cattr_accessor :show_exceptions
  cattr_accessor :require_user_email
  cattr_accessor :require_user_full_info
  cattr_accessor :domain
  cattr_accessor :translation_group
  cattr_accessor :chat
  cattr_accessor :signup_mode
  cattr_accessor :dev_email

  # are in site, but I think they should be global
  cattr_accessor :translators
  cattr_accessor :translation_group

  # are global, but might end up in site one day.
  cattr_accessor :profiles
  cattr_accessor :profile_fields
  cattr_accessor :limited

  # global instance options
  cattr_accessor :enabled_mods
  cattr_accessor :enabled_tools
  cattr_accessor :enabled_languages
  cattr_accessor :email
  cattr_accessor :sites
  cattr_accessor :secret
  cattr_accessor :paranoid_emails
  cattr_accessor :ensure_page_owner
  cattr_accessor :default_page_access
  cattr_accessor :text_editor

  # set automatically from site.admin_group
  cattr_accessor :super_admin_group_id

  # Global options that are set automatically by the code
  # For exampke, in initializers or in environments/*.rb.
  # Typically, you will never have to configured these.
  cattr_accessor :always_renegerate_themed_stylesheet
  cattr_accessor :enabled_site_ids

  # used for error reporting
  cattr_accessor :configuration_filename

  # cattr_accessor doesn't work with ?
  def self.chat?; self.chat; end
  def self.limited?; self.limited; end
  def self.paranoid_emails?; self.paranoid_emails; end
  def self.tracking?; self.tracking; end
  def self.ensure_page_owner?; self.ensure_page_owner; end

  ##
  ## LOADING
  ##

  def self.load_defaults
    self.name                 = 'default'
    self.super_admin_group_id = nil

    # site defaults
    self.title             = 'crabgrass'
    self.pagination_size   = 30
    self.default_language  = 'en_US'
    self.email_sender      = 'robot@$current_host'
    self.email_sender_name = '$site_title ($user_name)'
    self.tracking          = false
    self.evil              = {}
    self.available_page_types = []
    self.enforce_ssl       = false
    self.show_exceptions   = true
    self.domain            = 'localhost'
    self.chat              = true
    self.signup_mode       = SIGNUP_MODE[:default]
    self.dev_email         = ''

    # instance configuration
    self.enabled_mods  = []
    self.enabled_tools = []
    self.enabled_languages = []
    self.email         = nil
    self.sites         = []
    self.secret        = nil
    self.ensure_page_owner = true
    self.default_page_access = :admin
    self.text_editor   = TEXT_EDITOR[:greencloth_only]
  end

  def self.load(filename)
    self.load_defaults
    self.configuration_filename = [RAILS_ROOT, 'config', filename].join('/')
    hsh = YAML.load_file(configuration_filename) || {}
    hsh.each do |key, value|
      method = key.to_s + '='
      if self.respond_to?(method)
        self.send(method,value) unless value.nil?
      else
        puts "ERROR (%s): unknown option '%s'" % [configuration_filename,key]
      end
    end

    ## convert strings in config to numeric constants.
    ['SIGNUP_MODE', 'TEXT_EDITOR'].each do |const_string|
      const = ("Conf::"+const_string).constantize
      attr = const_string.downcase
      if self.send(attr).is_a? String
        unless const.has_key? self.send(attr).to_sym
          raise Exception.new('%s of "%s" is not recognized' % [attr, self.send(attr)])
        end
        self.send(attr+'=', const[self.send(attr).to_sym])
      end
    end

    ## convert some strings in config to symbols
    ['default_page_access'].each do |conf_var|
      self.send(conf_var+'=', self.send(conf_var).to_sym)
    end

    return true
  end

  ##
  ## SITES
  ##

  # can be called from a test's setup method in order to enable sites
  # for a particular set of tests without enabling sites for all tests.
  def self.enable_site_testing(site = nil)
    enabled_ids = site ? [site.id] : [1, 2]
    self.enabled_site_ids = enabled_ids
  end

  def self.disable_site_testing
    self.enabled_site_ids = []
  end

  ##
  ## PLUGINS
  ##

  # Called by lib/extension/engines.rb in order to determine if a plugin should
  # be loaded. Normal plugins are always loaded, we just might have disabled
  # mods and tools.
  def self.plugin_enabled?(plugin_path)
    if plugin_path =~ /^#{RAILS_ROOT}\/mods\//
      self.mod_enabled?( File.basename(plugin_path) )
    elsif plugin_path =~ /^#{RAILS_ROOT}\/tools\//
      self.tool_enabled?( File.basename(plugin_path) )
    else
      true
    end
  end

  # a mod will be enabled if explicitly configured to be so, or if
  # ENV['MOD'] is set.
  def self.mod_enabled?(mod_name)
    self.enabled_mods.include?(mod_name) or ENV['MOD'] == mod_name
  end

  # tools are like mods, except that the default is to enable all tools
  # unless only some are enabled.
  def self.tool_enabled?(tool_name)
    self.enabled_tools.empty? or self.enabled_tools.include?(tool_name) or ENV['TOOL'] == tool_name
  end

  ##
  ## CONVENIENCE METHODS
  ##

  def self.allow_greencloth_editor?
    self.text_editor != TEXT_EDITOR[:html_only]
  end

  def self.allow_html_editor?
    self.text_editor != TEXT_EDITOR[:greencloth_only]
  end

  def self.text_editor_sym
    @@text_editor_symbols ||= TEXT_EDITOR.invert
    @@text_editor_symbols[self.text_editor]
  end

end


