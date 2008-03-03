require File.dirname(__FILE__) + '/test_helper'

class MigrationTest < Test::Unit::TestCase
  include CaptureStdout
  
  def setup
    ENV["RAILS_ENV"] = "test"
    capture_stdout do
      Rake.application.handle_options
      Rake.application.load_rakefile
    end
    ENV.delete("VERSION") if ENV["VERSION"]
    
    migrate_db
    @connection = ActiveRecord::Base.connection
  end
  
  def teardown
    ENV["VERSION"] = "0"
    migrate_db
  end
  
  def test_migrations_ran
    recipes = @connection.select_all("SELECT * FROM recipes")
    assert recipes.length > 0
  end

  def test_previous_migration_number_runs
    # Simulate a migration with a lower migration number having not been run yet
    @connection.execute "DELETE FROM migrations_info WHERE id = '1193800624'"
    @connection.execute "DELETE FROM recipes WHERE owner = 'user1'"
    recipes = @connection.select_all("SELECT * FROM recipes WHERE owner = 'user1'")
    assert recipes.length == 0
    
    migrate_db
    recipes = @connection.select_all("SELECT * FROM recipes WHERE owner = 'user1'")
    assert recipes.length > 0
  end

  def test_migrate_previous
    ENV["VERSION"] = "previous"
    migrate_db

    recipes = @connection.select_all("SELECT * FROM recipes WHERE owner = 'user2'")
    assert recipes.length == 0
  end

  def test_migrate_next
    test_migrate_previous
    ENV["VERSION"] = "next"
    migrate_db

    recipes = @connection.select_all("SELECT * FROM recipes WHERE owner = 'user2'")
    assert recipes.length > 0
  end
  
  def test_migrate_first
    ENV["VERSION"] = "first"
    migrate_db

    recipes = @connection.select_all("SELECT * FROM recipes WHERE owner = 'user1'")
    assert recipes.length == 0
  end

  def test_migrate_last
    test_migrate_first

    ENV["VERSION"] = "last"
    migrate_db
    recipes = @connection.select_all("SELECT * FROM recipes WHERE owner = 'user2'")
    assert recipes.length > 0
  end

  def test_migrate_previous_at_zero_migration
    ENV["VERSION"] = "0"
    migrate_db
    
    ENV["VERSION"] = "previous"
    assert_raises(RuntimeError) { migrate_db }
  end

  def test_migrate_next_at_last_migration    
    ENV["VERSION"] = "next"
    assert_raises(RuntimeError) { migrate_db }
  end

  def test_schema_dump
    assert ActiveRecord::Base.connection.dump_schema_information.length == 3
  end

private

  def migrate_db
    reset_task_invocation('db:migrate')
    capture_stdout do
      Rake::Task['db:migrate'].invoke
    end
  end

  def reset_task_invocation(task)
    Rake::Task['enhanced_migrations:set_env'].instance_variable_set(:@already_invoked, false)
    Rake::Task[task].instance_variable_set(:@already_invoked, false)
  end

end