require File.dirname(__FILE__) + '/../test_helper'

# This test does not require database access :)

class GroupAccessTest < Test::Unit::TestCase

  def setup
    @group = Group.make
    @user = mock
  end

  def test_has_admin_access_without_council
    @user.expects(:member_of?).with(@group).returns(true).times(2)
    assert @group.has_access!(:admin, @user)
    assert @group.has_access?(:admin, @user)
  end

  def test_has_admin_access_with_council
    council = Council.make
    @group.add_committee!(council, true)
    @user.expects(:member_of?).with(council).returns(true).times(2)
    assert @group.has_access!(:admin, @user)
    assert @group.has_access?(:admin, @user)
  end

  def test_has_no_admin_access
    @user.expects(:member_of?).with(@group).returns(false).times(2)
    assert_raises PermissionDenied do
      @group.has_access!(:admin, @user)
    end
    assert !@group.has_access?(:admin, @user)
  end

  def test_has_no_admin_access_with_council
    council = Council.make
    @group.add_committee!(council, true)
    @user.expects(:member_of?).with(council).returns(false).times(2)
    assert_raises PermissionDenied do
      @group.has_access!(:admin, @user)
    end
    assert !@group.has_access?(:admin, @user)
  end

  def test_has_edit_access
    @user.expects(:member_of?).with(@group).returns(true).times(2)
    assert @group.has_access!(:edit, @user)
    assert @group.has_access?(:edit, @user)
  end

  def test_has_edit_access_with_council
    @user.stubs(:member_of?).with(@group).returns(false)
    council = Council.make
    @group.add_committee!(council, true)
    @user.expects(:member_of?).with(council).returns(true).times(2)
    assert @group.has_access!(:edit, @user)
    assert @group.has_access?(:edit, @user)
  end

  def test_has_no_edit_access
    @user.expects(:member_of?).with(@group).returns(false).times(4)
    assert_raises PermissionDenied do
      @group.has_access!(:edit, @user)
    end
    assert !@group.has_access?(:edit, @user)
  end

  def test_has_view_access
    @user.expects(:member_of?).with(@group).returns(true).times(2)
    assert @group.has_access!(:view, @user)
    assert @group.has_access?(:view, @user)
  end

  def test_has_public_view_access
    @user.stubs(:member_of?).returns(false)
    @group.profiles.public.expects(:may_see?).returns(true).times(2)
    assert @group.has_access!(:view, @user)
    assert @group.has_access?(:view, @user)
  end

  def test_has_no_view_access
    @user.stubs(:member_of?).returns(false)
    @group.profiles.public.expects(:may_see?).returns(false).times(2)
    assert_raises PermissionDenied do
      @group.has_access!(:view, @user)
    end
    assert !@group.has_access?(:view, @user)
  end


end
