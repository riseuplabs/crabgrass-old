# do this early because environments/*.rb need it
require 'lib/crabgrass/config'

# get list of mods to enable (before plugins are loaded)
MODS_ENABLED = File.read("#{RAILS_ROOT}/config/mods_enabled.list").split("\n").freeze
TOOLS_ENABLED = File.read("#{RAILS_ROOT}/config/tools_enabled.list").split("\n").freeze

begin
  secret_path = File.join(RAILS_ROOT, "config/secret.txt")
  Crabgrass::Config.secret = File.read(secret_path).chomp
rescue
  unless ARGV.first == "create_a_secret"
    raise "Can't load the secret key from file #{secret_path}. Have you run 'rake create_a_secret'?"
  end
end  

# TODO: banish SECTION_SIZE and replace with Site.current.pagination_size
SECTION_SIZE = 29


# this is not actually used, but i think it is so cool that i want to keep
# it around in case we need it.
=begin
require 'dispatcher'

module AfterMethod

  ##
  ## AFTER RESET APPLICATION
  ## 
  ## read all about it here:
  ## http://blog.nanorails.com/articles/2007/2/15/after_method
  ##

  #
  # a method to add an 'after' callback to any class.method(). 
  #
  def self.after_method(klass, target, feature, &block)
    # Strip out punctuation on predicates or bang methods since
    # e.g. target?_without_feature is not a valid method name.
    aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ''), $1
    class << klass; self end.class_eval do
      define_method("register_#{feature}", &block)
      define_method("#{aliased_target}_with_#{feature}#{punctuation}") {
        returning klass.send("#{aliased_target}_without_#{feature}#{punctuation}") do
          klass.send("register_#{feature}")
        end
      }
      alias_method_chain target, "#{feature}" 
    end
    klass.send("register_#{feature}")
  end

  #
  # When you extend a class in a plugin that is in the rails project, rails will
  # unload that class in development mode. This is a problem. So, what we do here
  # is create a way to extend a class __each time it gets reloaded__. This only
  # pertains to development mode.
  #
  # You use it like this in the plugin's init.rb:
  #
  # after_cleanup_application("erubis_registration") {
  #  Site.register_template_handler(".erubis", ErubisTemplate)
  # }
  #

  def self.after_cleanup_application(feature, &block)
    debugger
    self.after_method(Dispatcher, :cleanup_application, feature, &block)
  end

end
=end
