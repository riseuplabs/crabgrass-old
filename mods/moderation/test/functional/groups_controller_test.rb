require File.dirname(__FILE__) + '/../test_helper'
class GroupsControllerTest < ActionController::TestCase
  fixtures :users, :groups, :memberships, :sites

  def setup
    @page = DiscussionPage.create :owner => users(:penguin),
      :created_by => users(:penguin),
      :updated_by => users(:penguin),
      :title => 'valid page'
    @page.add(users(:penguin), :changed_at => Time.now).save
    @page.add(groups(:animals)).save
    @page.save
    # this is done by the student mod on cc.net but testing
    # two mods in parallel is troublesome.
    @controller.stubs(:may_contributions_group?).returns true
  end

  def test_contributions
    with_site :site1, :moderation_group => groups(:rainbow) do
      login_as :blue
      get :contributions, :id => groups(:animals).to_param
      assert_response :success
      assert assigns['pages'].include? @page
    end
  end

  def test_contributions_do_not_list_moderators
    @page.add(users(:blue)).save
    @page.updated_by = users(:blue)
    @page.save
    with_site :site1, :moderation_group => groups(:rainbow) do
      login_as :blue
      get :contributions, :id => groups(:animals).to_param
      assert_response :success
      assert pages = assigns['pages']
      assert pages.select{|p| p.updated_by_login == 'penguin'}.include? @page
      assert pages.select{|p| p.updated_by_login == 'blue'}.empty?
    end
  end

  def test_contributions_do_not_list_super_admins
    with_site :site1, :moderation_group => groups(:rainbow) do
      login_as :blue
      Site.any_instance.stubs(:super_admin_group).returns(groups(:animals))
      get :contributions, :id => groups(:animals).to_param
      assert_response :success
      assert_equal [], assigns['pages']
    end
  end

end

