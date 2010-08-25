#
# allows a rails plugin to modify one of the core models of the app.
#
# just add 'acts_as_extensible' to the model definition, and
# plugins will be able to add stuff nilly willy to the class
# definition of the model.
#
# class Cat
#   has_many :lives
#   acts_as_extensible
# end
#
# in the plugin init.rb:
#
# add_to_model('Cat', lambda{
#   has_many :claws
# })
#

require 'active_record'

module Mods::ActsAsExtensible
  def self.included(base)
    base.send :extend, ClassMethods
  end
  module ClassMethods
    def acts_as_extensible(options = {})
      Mods.get_model_mixins(self.name.to_s).each do |mixin|
        self.class_eval &(mixin)
      end
    end
  end
end

ActiveRecord::Base.send :include, Mods::ActsAsExtensible
