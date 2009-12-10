require 'test/unit'
require 'rubygems'
require 'active_record'
require 'ruby_debug'

require "#{File.dirname(__FILE__)}/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
RAILS_DEFAULT_LOGGER = Logger.new(STDOUT)

##
## DEFINE DB
##

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :things do |t|
      t.column :site_id, :integer
      t.column :bundle_id, :integer
      t.column :name, :string
    end
    create_table :sites do |t|
      t.column :name, :string
      t.column :limited, :boolean, :default => true
    end
    create_table :bundles do |t|
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

def reset_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.execute("DELETE FROM #{table};")
  end
end

##
## DEFINE MODELS
##

class Site < ActiveRecord::Base
  def self.current
    @current
  end
  def self.current=(value)
    @current = value
  end
end

class Thing < ActiveRecord::Base
  belongs_to :bundle
  acts_as_site_limited
  named_scope :by_name, {:order => 'name DESC'}
end

class Bundle < ActiveRecord::Base
  has_many :things
  has_many :conditional_things, :class_name => "Thing", :conditions => "name = 'b'"
  has_many :things_by_sql, :class_name => "Thing", :finder_sql => 'SELECT things.* FROM things WHERE /*SITE_LIMITED*/'
end

##
## TEST
##

setup_db

class ActsAsSiteLimitedTest < Test::Unit::TestCase

  def setup
    Site.create! :name => '1'
    Site.create! :name => '2'
  end

  def teardown
    reset_db
  end

  def test_creation
    Site.current = Site.find_by_name(1)
    thing = Thing.create!
    assert_equal Site.current.id, thing.site_id, 'should auto set site id'

    Site.current = nil
    thing = Thing.create!
    assert_nil thing.site_id, 'should not set site id'
  end

  def test_finders
    Site.current = Site.find_by_name(1)
    thing1a = Thing.create! :name => 'a'
    thing1b = Thing.create! :name => 'b'
    Site.current = Site.find_by_name(2)    
    thing2a = Thing.create! :name => 'a'
    thing2b = Thing.create! :name => 'b'
    thing2c = Thing.create! :name => 'c'

    things = Thing.find(:all)
    assert_equal 3, things.size, 'there should be three things for site 2'

    Site.current = Site.find_by_name(1)
    things = Thing.find(:all)
    assert_equal 2, things.size, 'there should be two things for site 1'

    Site.current = Site.find_by_name(2)
    things = Thing.find(:all, :order => "name DESC")
    assert_equal 3, things.size
    assert_equal thing2c.id, things.first.id

    things = Thing.find(:all, :conditions => "name = 'b'")
    assert_equal 1, things.size
    assert_equal thing2b.id, things.first.id

    thing = Thing.find_by_name('b')
    assert_equal thing2b.id, thing.id

    Site.current = Site.find_by_name(1)
    thing = Thing.find_by_name('b')
    assert_equal thing1b.id, thing.id
  end

  def test_associations
    Site.current = Site.find_by_name(1)
    bundle = Bundle.create!
    bundle.things.create! :name => 'a'
    bundle.things.create! :name => 'b'
    Site.current = Site.find_by_name(2)
    bundle.things.create! :name => 'c'
    bundle.reload

    assert_equal 1, bundle.things.find(:all).size
    assert_equal 1, bundle.things.size
    assert_equal 1, bundle.things.collect.size
  end

  def test_conditional_association
    Site.current = Site.find_by_name(1)
    bundle = Bundle.create!
    bundle.things.create! :name => 'a'
    bundle.things.create! :name => 'b'
    
    assert_equal 'b', bundle.conditional_things.first.name    
  end

  def test_named_scope
    Site.current = Site.find_by_name(1)
    Thing.create! :name => 'z'

    Site.current = Site.find_by_name(2)
    Thing.create! :name => 'a'
    Thing.create! :name => 'b'
    assert_equal 'b', Thing.by_name.first.name

    Site.current = Site.find_by_name(1)
    assert_equal 'z', Thing.by_name.first.name
  end

  def test_sql_finder
    Site.current = Site.find_by_name(1)
    bundle = Bundle.create!
    bundle.things.create! :name => 'a'
    bundle.things.create! :name => 'b'
    
    assert_equal 2, bundle.things_by_sql.count
    assert_equal 'a', bundle.things_by_sql.first.name
  end

end
