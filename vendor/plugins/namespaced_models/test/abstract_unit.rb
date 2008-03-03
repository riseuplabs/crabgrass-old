ENV['RAILS_ENV'] = 'test'
require 'test/unit'

begin
  require File.dirname(__FILE__) + '/../../../../config/environment'
rescue
  require 'rubygems'
  require_gem 'activerecord'
  require 'active_record/fixtures'
end

ActiveRecord::Base.configurations = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
ActiveRecord::Base.establish_connection(ENV['DB'] || 'mysql')

load(File.dirname(__FILE__) + '/schema.rb')

require File.expand_path(File.dirname(__FILE__) + '/../lib/namespaced_models')

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures/"
Dependencies.load_paths.insert(0, Test::Unit::TestCase.fixture_path)

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end
