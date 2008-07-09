FightTheMelons::Helpers::FormMultipleSelectHelperConfiguration.outer_class = 'plainlist' if defined? FightTheMelons

if File.exists?('.svn')
  SVN_REVISION = (RAILS_ENV != 'test' && r = YAML.load(`svn info`)) ? r['Revision'] : nil
else
  SVN_REVISION = nil
end
