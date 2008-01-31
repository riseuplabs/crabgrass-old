require File.dirname(__FILE__) + '/../test_helper'

class UnauthenticatedUserTest < Test::Unit::TestCase

  def setup
    @user = UnauthenticatedUser.new
  end

  def test_should_be_able_to_view_public_page
    assert @user.may?(:view, Page.new(:public => true))
  end
  def test_should_be_able_to_read_public_page
    assert @user.may?(:read, Page.new(:public => true))
  end

  def test_should_not_be_able_to_view_public_page
    assert !@user.may?(:view, Page.new(:public => false))
  end
  def test_should_not_be_able_to_read_public_page
    assert !@user.may?(:read, Page.new(:public => false))
  end

  def test_method_missing_raises_permission_denied
    assert_raise(PermissionDenied) do
      @user.an_unimplemented_method
    end
  end
end
