# levels of page access
# why is setting a default a good idea?
#ACCESS = (Hash.new(3).merge({:admin => 1, :edit => 2, :view => 3})).freeze
#ACCESS_TO_SYM = (Hash.new(:view).merge({1 => :admin, 2 => :edit, 3 => :view})).freeze

ACCESS = HashWithIndifferentAccess.new({:admin => 1, :edit => 2, :view => 3, :none => nil}).freeze
ACCESS_TO_SYM = {1 => :admin, 2 => :edit, 3 => :view}.freeze

ACCESS_ADMIN = 1
ACCESS_EDIT = 2
ACCESS_VIEW = 3

# types of page flows
FLOW = {:deleted => 3, :gallery => 4, :announcement => 5}.freeze

# enum of media types
MEDIA_TYPE = {
  :image => 1, 
  :audio => 2,
  :video => 3,
  :document => 4
}.freeze

ARROW = " &raquo; "
BULLET = " &bull; "
RARROW = " &raquo; "
LARROW = " &laquo; "

# group and user names which cannot be used
FORBIDDEN_NAMES = %w(account admin assets avatars chat calendar calendars contact custom_appearances embed event events feeds files gibberize group groups images invites issues javascripts latex me membership messages network networks page pages people person posts profile places plugin_assets requests static stats stylesheets visualize wiki code codes).freeze

# a time to use when displaying recent records
RECENT_SINCE_TIME = 2.weeks.ago.freeze

begin
  # get a list of possible translations, ones there is a file for.
  possible = Dir.glob([RAILS_ROOT,'lang','*.yml'].join('/')).collect{ |file|
    File.basename(file).sub('.yml','')
  }

  # intersect with the enabled langs in configuration
  if Conf.enabled_languages.any?
    lang_codes = possible & Conf.enabled_languages 
  else
    lang_codes = possible
  end
  LANGUAGES = Language.find(:all, :conditions => ['code IN (?)',lang_codes]).freeze
  AVAILABLE_LANGUAGE_CODES = lang_codes.collect{|code| code.sub('_','-')}.freeze
rescue Exception
  # something went wrong.
  LANGUAGES = []
end
