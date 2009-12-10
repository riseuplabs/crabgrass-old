require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase

  def test_cracklib

    assert_raises ActiveRecord::RecordInvalid do
      User.create! :login => 'adorno',
        :password => '1234567',
        :password_confirmation => '1234567'
    end

    assert_raises ActiveRecord::RecordInvalid do
      User.create! :login => 'foucault',
        :password => 'foucault',
        :password_confirmation => 'foucault'
    end

    assert_raises ActiveRecord::RecordInvalid do
      User.create! :login => 'marcuse',
        :password => 'aaaaaaa',
        :password_confirmation => 'aaaaaaa'
    end

    assert_nothing_raised do
      User.create! :login => 'weber',
        :password => 'chae8naH',
        :password_confirmation => 'chae8naH'
    end

  end

end

