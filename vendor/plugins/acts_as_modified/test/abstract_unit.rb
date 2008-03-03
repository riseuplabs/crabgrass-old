require 'test/unit'

begin
  require File.dirname(__FILE__) + '/../../../../config/boot'
  Rails::Initializer.run
rescue LoadError
  require 'rubygems'
  require_gem 'activerecord'
end

# Search for fixtures first
fixture_path = File.dirname(__FILE__) + '/fixtures/'
begin
  Dependencies.load_paths.insert(0, fixture_path)
rescue
  $LOAD_PATH.unshift(fixture_path)
end

require 'active_record/fixtures'

require File.dirname(__FILE__) + '/../lib/acts_as_modified'

ActiveRecord::Base.configurations = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
ActiveRecord::Base.establish_connection(ENV['DB'] || 'mysql')

load(File.dirname(__FILE__) + '/schema.rb')

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + '/fixtures/'

class Test::Unit::TestCase #:nodoc:
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end
