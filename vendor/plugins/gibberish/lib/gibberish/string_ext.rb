module Gibberish
  module StringExt

#
# DISABLED ORIGINAL CODE
#

#    def brackets_with_translation(*args)
#      args = [underscore.tr(' ', '_').to_sym] if args.empty?
#      return brackets_without_translation(*args) unless args.first.is_a? Symbol
#      Gibberish.translate(self, args.shift, *args)
#    end

## BEGIN CRABGRASS HACK

    # allow any translated string to be overridden for a site
    # unfortunately, this relies on Site.current, which I do not like at
    # all, but we need this ability.
    def brackets_with_translation(*args)
      args = [underscore.tr(' ', '_').to_sym] if args.empty?
      first = args.first
      if !first.is_a?(String) and !first.is_a?(Symbol) 
        return brackets_without_translation(*args)
      elsif Site.current.nil?
        return Gibberish.translate(self, args.shift, *args)  
      end

      key = args.shift
      site_key = "#{key}_for_site_#{Site.current.name}"
      if Gibberish.translations[site_key]
        Gibberish.translate(self, site_key, *args)
      else
        Gibberish.translate(self, key, *args)
      end
    end

## END CRABGRASS HACK

    def self.included(base)
      base.class_eval do
        alias :brackets :[]
        alias_method_chain :brackets, :translation
        alias :[] :brackets
      end
    end
  end
end
