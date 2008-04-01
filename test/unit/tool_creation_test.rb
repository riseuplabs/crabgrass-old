require File.dirname(__FILE__) + '/../test_helper'

class ToolCreationTest < Test::Unit::TestCase

  def test_add_participants
    @controller = Tool::BaseController.new
    page = Page.create(:title => 'add participants page')
    creator = User.new
    member = User.new
    Group.expects(:get_by_name).with('groupname').returns(group = Group.new)
    group.stubs(:users).returns([creator, member])
    @controller.stubs(:current_user).returns(creator)
    page.expects(:add).with(creator, any_parameters)
    page.expects(:add).with(member, any_parameters)
    page.expects(:add).with(group, any_parameters)
    @controller.send(:add_participants!, page, {:group_name => 'groupname', :announce => true}) #or group_id
  end
end
