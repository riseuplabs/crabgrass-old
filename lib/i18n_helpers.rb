=begin

ways to translate a string:

  "Hello"[:hello]
  "Hello".t
  :hello.t
  "Hello %s" / id
  _('Hello')

Too many! _ and / should not be used.

=end

class String

  def /(*args)
    self.t().%(*args)
  end

  # discard capitalization
  alias :t :[]

end 

def _(str)
  str[]
end

class Symbol
  def t()
    self.to_s.t(self)
  end
end

#
# override the gibberish translation method
#
# NOTE: 
# This relies on a hack to Gibberish which turns
# Gibberish.translations[x] from a Hash to a HashWithIndifferentAccess
# (we don't want to create a bunch of symbols that are never
# going to be used)
#
#
# NOTE 2:
# this is moved to gibberish plugin, because I can't figure out how to get
# it working here.
#

#class String
#  # allow any translated string to be overridden for a site
#  # unfortunately, this relies on Site.current, which I do not like at
#  # all, but we need this ability.
#  def brackets_with_translation(*args)
#    args = [underscore.tr(' ', '_').to_sym] if args.empty?
#    first = args.first
#    if !first.is_a?(String) and !first.is_a?(Symbol) 
#      brackets_without_translation(*args)
#    elsif Gibberish.translations[first]
#      key = args.shift
#      site_key = "#{key}_for_site_#{Site.current.name}"
#      if Gibberish.translations[site_key]
#        Gibberish.translate(self, site_key, *args)
#      else
#        Gibberish.translate(self, key, *args)
#      end
#    else
#      brackets_without_translation(*args)
#    end
#  end
#end


