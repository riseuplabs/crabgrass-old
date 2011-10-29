require File.dirname(__FILE__) + '/../test_helper'

# This test does not require database access :)

class UserTest < Test::Unit::TestCase

  def setup
    @user = User.make
    @target = mock
    @target.stubs(:new_record?).returns(false)
  end

  def test_may_nil_returns_false
    assert !@user.may?(:test, nil)
    assert !@user.may!(:test, nil)
  end

  def test_may_new_record
    @target.expects(:new_record?).returns(true).times(2)
    assert @user.may?(:test, @target)
    assert @user.may!(:test, @target)
  end

  def test_may?
    @target.expects(:has_access!).with(:permission, @user).returns(true)
    assert @user.may?(:permission, @target)
  end

  def test_may_not
    @target.expects(:has_access!).with(:permission, @user).raises(PermissionDenied)
    assert !@user.may?(:permission, @target)
  end

  def test_may!
    @target.expects(:has_access!).with(:permission, @user).returns(true)
    assert @user.may!(:permission, @target)
  end

  def test_may_raises
    @target.expects(:has_access!).with(:permission, @user).raises(PermissionDenied)
    assert_raises PermissionDenied do
      @user.may!(:permission, @target)
    end
  end

  def test_may_caches
    @target.expects(:has_access!).with(:permission, @user).returns(true)
    # filling the cache
    assert @user.may!(:permission, @target)
    @target.stubs(:has_access!).returns(false)
    # using the cached version
    assert @user.may?(:permission, @target)
    @user.clear_access_cache
    assert !@user.may?(:permission, @target)
  end

  def test_cache_is_key_specific
    @target.expects(:has_access!).with(:permission, @user).returns(true)
    @target.expects(:has_access!).with(:test, @user).returns(false)
    # filling the cache
    assert @user.may!(:permission, @target)
    # cache only affects key
    assert !@user.may?(:test, @target)
  end

  def test_cache_is_target_specific
    other = mock
    other.stubs(:new_record?).returns(false)
    @target.expects(:has_access!).with(:permission, @user).returns(true)
    other.expects(:has_access!).with(:permission, @user).returns(false)
    # filling the cache
    assert @user.may!(:permission, @target)
    # cache only affects this @target
    assert !@user.may?(:permission, other)
  end

end

