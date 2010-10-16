require 'active_support'

module Mods; end
require File.join(File.dirname(__FILE__), 'mods/acts_as_extensible')
require File.join(File.dirname(__FILE__), 'mods/plugin')
require File.join(File.dirname(__FILE__), 'mods/plugin/loader')
require File.join(File.dirname(__FILE__), 'mods/plugin/locator')

module Mods

  private

  # used for mods to register a new model mixin. 
  mattr_accessor :model_mixins
  self.model_mixins = {}

  # used by the application to determine which plugins to enable or disable.
  # if set, this callback is passed the directory path of the plugin, and
  # returns true or false.
  mattr_accessor :plugin_enabled_callback

  # used by the application to determine which plugins to auto-reload in
  # development mode. With mods enabled, a plugin can call 'reloadable()' in
  # its init.rb. Otherwise, the application can set a callback here to 
  # globally decide based on the path of the plugin. The callback, given the
  # plugin path, should return true if the plugin should be reloadable.
  mattr_accessor :plugin_reloadable_callback

  public

  def self.add_model_mixin(model_name, lambda_block)
    raise Exception.new('second arg must be a lambda_block') unless lambda_block.instance_of? Proc

    Mods.model_mixins[model_name] ||= []
    Mods.model_mixins[model_name] << lambda_block
  end

  def self.get_model_mixins(model_name)
    Mods.model_mixins[model_name]
  end

 
end

