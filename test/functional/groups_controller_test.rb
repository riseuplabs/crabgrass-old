require File.dirname(__FILE__) + '/../test_helper'

class GroupsControllerTest < ActionController::TestCase
  fixtures :groups, :users, :memberships, :profiles, :pages, :sites,
            :group_participations, :user_participations, :tasks, :page_terms, :task_lists

  include UrlHelper

  def setup
    Conf.disable_site_testing
  end

  def test_tasks
    login_as :blue
    get :tasks, :id => groups(:rainbow).to_param
    assert_response :success
  end

  def test_discussions
    login_as :blue
    get :discussions, :id => groups(:rainbow).to_param
    assert_response :success
  end

  def test_archive
    login_as :blue
    get :archive, :id => groups(:rainbow).to_param, :path => ['created']
    assert_response :success
  end

  def test_create_group
    get :new
    assert_login_required

    login_as :gerrard
    get :new
    assert_response :success

    assert_no_difference 'Group.count' do
      post :create, :group => {:name => ''}
      assert_error_message
    end

    assert_no_difference 'Group.count' do
      post :create, :group => {:name => 'animals'}
      assert_error_message
    end

    assert_difference 'Group.count' do
      post :create, :group => {:name => 'test-create-group', :full_name => "Group for Testing Group Creation!"}
      assert_response :redirect
      group = Group.find_by_name 'test-create-group'
      assert_redirected_to url_for_group(group, :action => 'edit')
    end
  end

=begin
  def test_get_create
    login_as :gerrard
    get :create

    assert_response :success
    assert_select "form#createform"
  end


#  def test_create_group_with_council
#    login_as :gerrard
#    assert_difference 'Group.count', 2 do
#      post :create, :group => {:name => 'group-with-council', :full_name => "Group for Testing Group Creationi with council!", :summary => "None."}, :add_council => "true"
#      assert_response :redirect
#      group = Group.find_by_name 'group-with-council'
#      assert_redirected_to url_for_group(group, :action => 'show')
#      assert_equal assigns(:group).name, 'group-with-council'
#      assert_equal group.name, 'group-with-council'
#      council = Group.find_by_name 'group-with-council+group-with-council_admin'
#      assert council.council?
#      assert_equal council.id, group.council.id
#    end
#  end

  def test_create_committee
    login_as :gerrard
    num_groups = Group.count
    num_committees = Committee.count
    # simulate user creating a committee:
    #    first a get request to get the page with the committee creation form
    get :create, :parent_id => groups(:true_levellers).id, :id => 'committee'
    assert_equal num_committees, Committee.count, "should not be an additional committee yet"
    #    then a post request to submit the committee creation form
    post :create, :parent_id => groups(:true_levellers).id, :group => {:name => 'committee', :full_name => "committee!", :summary => ""}, :id => 'committee'
    assert_equal num_committees + 1, Committee.count, "should be an additional committee now"
    assert_equal num_groups + 1, Group.count, "the new committee should also be counted as a new group"
  end

  def test_create_committee_when_not_member_of_group
    login_as :gerrard

    assert_difference 'Committee.count', 1, "should create a new committee" do
      post :create, :parent_id => groups(:true_levellers).id, :group => {:short_name => 'committee', :full_name => "committee!", :summary => ""}, :id => 'committee'
    end

    assert_no_difference 'Committee.count', "should not create a new committee, since gerrard is not in rainbow group" do
      post :create, :parent_id => groups(:rainbow).id, :group => {:short_name => 'committee', :full_name => "committee!", :summary => ""}, :id => 'committee'
    end
  end

  def test_create_fails_when_name_is_taken
    login_as :gerrard
    assert_difference 'Group.count', 1,  "should have created a new group" do
      post :create, :group => {:name => 'test-create-group'}
    end

    assert_no_difference 'Group.count', "should not create group with name of an existing group" do
      post :create, :group => {:name => 'test-create-group'}
    end

    assert_no_difference 'Group.count', "should not create group with name of an existing user" do
      post :create, :group => {:name => users(:gerrard).login}
    end
  end

=end


  def test_show_when_logged_in
    login_as :red

    # show a group you belong to
    get :show, :id => groups(:rainbow).to_param
    assert_response :success
#    assert_template 'show'

    assert_not_nil assigns(:group)
    assert assigns(:group).valid?

    assert_not_nil assigns(:access)
    assert_equal :private, assigns(:access), "red should have access to private group information for :rainbow"
    assert_select "section#identity-name div#group-action a", "Leave Group"

    #show a committee you belong to
    get :show, :id => groups(:warm).to_param
    assert_response :success
#    assert_template 'show'
    assert assigns(:group).valid?

    # show a public group you don't belong to
    get :show, :id => groups(:public_group).to_param
    assert_response :success
#    assert_template 'show'

    assert_not_nil assigns(:group)
    assert assigns(:group).valid?

    assert_not_nil assigns(:access)
    assert_equal :public, assigns(:access), "red should only have access to public group information for :public_group"
    assert_raise Test::Unit::AssertionFailedError do
      assert_select "section#identity-name div.left a", "Leave Group"
    end

    # show nothing for a private group you don't belong to
    get :show, :id => groups(:private_group).to_param
    assert_response :missing
    assert_template 'dispatch/not_found'
  end

  def test_show_committees_when_logged_in
    login_as :blue

    # show a group you belong to
    get :show, :id => groups(:public_group).to_param
    assert_response :success
#    assert_template 'show'

    assert_equal :private, assigns(:access), "should have private access to public group"
    assert_equal 2, assigns(:group).committees_for(assigns(:access)).length, "should show 2 committee"

  end

  def test_show_public_when_not_logged_in
    get :show, :id => groups(:public_group).name
    assert_response :success
#    assert_template 'show'
    assert_equal :public, assigns(:access), "should have public access to public group"
    assert_equal 1, assigns(:group).committees_for(assigns(:access)).length, "should show 1 committee"

    get :show, :id => groups(:public_committee).name
    assert_response :success
#    assert_template 'show'
    assert_equal :public, assigns(:access), "should have public access to public committee of public group"
  end

  def test_show_private_when_not_logged_in
    get :show, :id => groups(:private_group).name
    assert_response 401
    assert_nil assigns(:access), "should have no access to private group"

    get :show, :id => groups(:warm).name
    assert_response 401
    assert_nil assigns(:access), "should have no access to private committee"

    get :show, :id => groups(:private_committee).name
    assert_response 401
    assert_nil assigns(:access), "should have no access to private committee of public group"
  end

  def test_archive_logged_in
    login_as :red

    get :archive, :id => groups(:rainbow).name
    assert_response :success, 'logged in, member of group should succeed'
    assert assigns(:group).valid?
    assert_not_nil assigns(:months)
    assert assigns(:months).length > 0, "should have some months"

    get :archive, :id => groups(:public_group).name
    assert_response :success, 'public group, logged in, should be found'
    assert assigns(:group).valid?

    get :archive, :id => groups(:public_group).name, :path => 'month/1/year/2008'
    assert_response :success

    get :archive, :id => groups(:private_group).name

  end

  def test_archive_not_logged_in
    get :archive, :id => groups(:public_group).to_param
    assert_response :success

    get :archive, :id => groups(:private_group).to_param
    assert_response :unauthorized
  end


  def test_search
    login_as :blue

    get :search, :id => groups(:rainbow).name

    assert_response :success
    assert_not_nil assigns(:pages)
    assert assigns(:pages).length > 0, "should have some search results"

    get :search, :id => groups(:rainbow).name, :path => 'type/discussion'
    assert_response :success
    assert_not_nil assigns(:pages)
    assert assigns(:pages).length > 0, "should have some search results when filter for discussions"

    post :search, :id => groups(:rainbow).name, :search => {:text => "e", :type => "", :person => "", :month => "", :year => "", :pending => "", :starred => ""}
    assert_response :redirect
#    assert_redirected_to :controller => :groups, :action => 'search', :path => [['text', 'e']], :id => groups(:rainbow)
    assert_not_nil assigns(:pages)
    assert assigns(:pages).length > 0, "should have some search results when filter for text"
  end

  def test_search_pagination
    blue = users(:blue)
    rainbow = groups(:rainbow)
    # we need enough pages to test pagination
    30.times {|i| Page.create!(:title => "page #{i}", :user => blue, :share_with => rainbow, :access => :view)}

    login_as :blue

    get :search, :id => rainbow.name, :path => ["descending", "updated_at"]

    assert_response :success
    assert_select 'div.pagination' do |es|
      assert_select 'a', {:text => "2"} do |as|
        as.each do |a|
          assert_equal "/groups/search/rainbow/descending/updated_at?page=2", a.attributes["href"]
        end
      end
    end
  end

  def test_search_when_not_logged_in
    get :search, :id => groups(:public_group).name
    assert_response :success

    post :search, :id => groups(:public_group).name, :search => {:text => "e", :type => "", :person => "", :month => "", :year => "", :pending => "", :starred => ""}
    assert_response :redirect
#    assert_redirected_to :controller => :groups, :action => 'search', :path => [['text', 'e']], :id => groups(:public_group)
  end

=begin
  def test_trash
    login_as :red

    get :trash, :id => groups(:rainbow).name
    assert_response :success
    assert_not_nil assigns(:pages)
    assert assigns(:pages).length > 0, "rainbow should have some page in the trash."

    get :trash, :id => groups(:rainbow).name, :path => 'type/discussion'
    assert_response :success
    assert_not_nil assigns(:pages)
    assert assigns(:pages).length > 0, "rainbow should have some discussion in the trash"

    post :trash, :id => groups(:rainbow).name, :search => {:text => "e", :type => "", :person => "", :month => "", :year => "", :pending => "", :starred => ""}
    assert_response :redirect
    assert_redirected_to 'group/trash/rainbow/text/e'
    assert_not_nil assigns(:pages)
    assert assigns(:pages).length > 0, "should have some search results when filter for text"
  end
=end

  def test_trash_not_allowed
    login_as :kangaroo
    get :trash, :id => groups(:private_group).name
    assert_response :missing
    assert_equal nil, assigns(:pages)
    post :trash, :id => groups(:private_group).name, :search => {:text => "e", :type => "", :person => "", :month => "", :year => "", :pending => "", :starred => ""}
    assert_response :missing
    assert_equal nil, assigns(:pages)
  end

=begin
  def test_trash_undelete
    login_as :red
    get :trash, :id => groups(:rainbow).name
    assert_response :success
    assert assigns(:pages).any?, "should find a deleted page"
    id = assigns(:pages).first.id
    assert_equal id, 207, "expecting page 207 as deleted page for rainbow"
    post :update_trash, :page_checked=>{"207"=>"checked"}, :path=>[], :undelete=>"Undelete", :id => groups(:rainbow).name
    assert_response :redirect
    assert_redirected_to 'group/trash/rainbow'
    get :trash
    assert_response :success
    assert assigns(:pages).empty?, "should not find a deleted page after undeleting"
  end
=end

  def test_tags
    login_as :blue

    get :tags, :id => groups(:rainbow).name
    assert_response :success
    assert_not_nil assigns(:pages)
  end

  def test_tags_not_allowed
    login_as :kangaroo
    get :tags, :id => groups(:private_group).name
    assert_response :missing
    assert_equal nil, assigns(:pages)
  end

  def test_tags_sql_inject
    login_as :blue
    get :tags, :id => groups(:rainbow).name, :path => "'))#"
    assert_response :success
    assert_equal [], assigns(:pages)
  end

  def test_tasks
    login_as :blue

    get :tasks, :id => groups(:rainbow).name
    assert_response :success
    assert_not_nil assigns(:pages)
    assert_not_nil assigns(:task_lists)
    assert assigns(:pages).length > 0, "should find some tasks"
  end

  def test_tasks_not_allowed
    login_as :kangaroo
    get :tasks, :id => groups(:private_group).name
    assert_response :missing
    assert_equal nil, assigns(:pages)
  end

  def test_edit

    login_as :blue
    get :edit, :id => groups(:rainbow).name

    assert_response :success

    assert_not_nil assigns(:group)
    assert assigns(:group).valid?

    new_name = "not-rainbow"
    new_full_name = "not a rainbow"
    new_summary = "new summary"

    group = Group.find(groups(:rainbow).id)

    post :update, :id => groups(:rainbow).name, :group => {
      :name => new_name,
      :full_name => new_full_name,
    }
    assert_equal assigns(:group), groups(:rainbow)

    group.reload
    assert_equal new_full_name, group.full_name, "full name should now be '#{new_full_name}'"
    assert_equal new_name, group.name, "group name should now be '#{new_name}'"

    # a sneaky hacker attack to watch out for
    g = Group.create! :name => 'hack-committee', :full_name => "hacker!"
    #Site.default.network.add_group! g unless Site.default.network.nil?
    assert_not_nil Group.find_by_name('hack-committee')
    post :edit, :id => 'hack-committee', :group => {:parent_id => groups(:rainbow).id}
    assert_nil Group.find_by_name('hack-committee').parent
  end

=begin
  def test_update
    login_as :blue
    post :update, :id => groups(:rainbow).name
    assert_response :redirect
    assert_redirected_to :action => 'edit', :id => groups(:rainbow).name

    # try changing the visibility settings
    post :update, :id => groups(:private_group).name,
            :group => { :publicly_visible_group => "1",
                        :publicly_visible_members => "1",
                        :publicly_visible_committees => "1",
                        :accept_new_membership_requests => "1" }
    groups(:private_group).reload
    assert_equal true, groups(:private_group).publicly_visible_group,
                   "private group should be public now"
    assert_equal true, groups(:private_group).publicly_visible_committees,
                   "private group should have public committees now"
    assert_equal true, groups(:private_group).publicly_visible_members,
                   "private group should have public membership now"
    assert_equal true, groups(:private_group).accept_new_membership_requests,
                   "private group should accept new membership requests"

    # make sure changing back works, too
    post :update, :id => groups(:private_group).name,
            :group => { :publicly_visible_group => "0",
                        :publicly_visible_members => "0",
                        :publicly_visible_committees => "0",
                        :accept_new_membership_requests => "0" }
    groups(:private_group).reload
    assert_equal false, groups(:private_group).publicly_visible_group,
                   "private group should be private again"
    assert_equal false, groups(:private_group).publicly_visible_committees,
                   "private group should not have public committees now"
    assert_equal false, groups(:private_group).publicly_visible_members,
                   "private group should not have public membership now"
    assert_equal false, groups(:private_group).accept_new_membership_requests,
                   "private group should not accept new membership requests"


    # try a sneaky hacker attack
    g = Group.create! :name => 'hack-committee', :full_name => "hacker!", :summary => ""
    #Site.default.network.add_group! g unless Site.default.network.nil?
    assert_not_nil Group.find_by_name('hack-committee')
    post :update, :id => 'hack-committee', :group => {:parent_id => groups(:rainbow).id}
    assert_nil Group.find_by_name('hack-committee').parent
  end

editing tools on a group basis has been abandoned iirc, azul
  def test_edit_tools
    login_as :blue

    post :edit_tools, :id => groups(:rainbow).name, :DiscussionPage => "on", :MessagePage => "on", :WikiPage => "on"
    groups(:rainbow).reload
    assert_equal true, groups(:rainbow).group_setting.allowed_tools.include?("DiscussionPage"),
                   "group should have Discussion page allowed"
    assert_equal true, groups(:rainbow).group_setting.allowed_tools.include?("MessagePage"),
                   "group should have Message page allowed"
    assert_equal true, groups(:rainbow).group_setting.allowed_tools.include?("WikiPage"),
                   "group should have Wiki page allowed"
    assert_equal false, groups(:rainbow).group_setting.allowed_tools.include?("AssetPage")
                   "group should not have Asset page allowed"
  end
=end

  def test_destroy
    login_as :gerrard

    assert_no_difference 'Group.count', "need to be only member to destroy a group" do
        delete :destroy, :id => groups(:true_levellers).name
    end

    group_name = 'short-lived-group'
    group = Group.create! :name => group_name
    # group.add_user! users(:gerrard)

    assert_difference 'Group.count', -1, "should delete newly created group" do
      delete :destroy, :id => group_name
      assert_redirected_to :controller => 'me'
    end
  end

  def test_login_required
    [:create, :edit, :destroy, :update,
      :edit_featured_content, :feature_content, :update_featured_pages
    ].each do |action|
      assert_requires_login(nil, @request.host) do |c|
        c.get action, :id => groups(:public_group).name
      end
    end

# should we test unlogged-in stuff on a private group?
#    [:create, :edit, :destroy, :update].each do |action|
#      get action, :id => groups(:private_group).name
#      assert_template 'not_found'
#    end
  end

  def test_member_of_committee_but_not_of_group_cannot_access_group_pages
#    enable_site_testing
    User.current = nil
    g = Group.create :name => 'riseup'

    c = Committee.create :name => 'outreach', :parent => g
    g.add_committee!(c)
    u = User.create! :login => 'user', :password => 'password', :password_confirmation => 'password'

    assert u.id
    c.add_user! u
    c.save
    u.reload

    group_page = DiscussionPage.create :title => 'a group page', :public => false
    group_page.add(g, :access => :admin)
    group_page.save
    committee_page = DiscussionPage.create :title => 'a committee page', :public => false, :owner => c
    committee_page.add(c, :access => :admin)
    committee_page.save

    @controller.stubs(:current_user).returns(u)
    @controller.stubs(:logged_in?).returns(true)
    @controller.instance_variable_set(:@group, c)
    assert u.may_admin?(c)
    assert @controller.may?(:group,:edit)

    get :show
    assert_response :success
    # assert_select "td.date", "Today"
    assert_select "a[href=?]", @controller.page_url(committee_page)

    @controller.instance_variable_set(:@group, g)
    get :show
    assert_select "a[href=?]", @controller.page_url(group_page), false
  end

  def test_people_when_not_logged_in
    get :people, :id => groups(:rainbow).name
    assert_response :redirect, "login required to list membership of a group"
    get :people, :id => groups(:private_group).name
    assert_response :unauthorized,
      "attempt to list private_group should return unauthorized."
  end

  def test_people
    login_as :red
    get :people, :id => groups(:rainbow).name
    assert_response :success, "list rainbow should succeed, because user red in group rainbow"

    groups(:public_group).profiles.public.may_see_members = true
    groups(:public_group).save!
    get :people, :id => groups(:public_group).name
    assert_response :success, "list public_group should succeed, because membership is public"

    get :people, :id => groups(:private_group).name
    assert_response :missing, "attempt to list private_group should return 404"

    groups(:public_group).profiles.public.may_see_members = false
    groups(:public_group).save!

    get :people, :id => groups(:public_group).name
    assert_response :success, "list public_group should succeed"
  end

  def test_list_groups_when_not_logged_in
    get :list_groups, :id => groups(:fai).name
    assert_response :redirect, "login required to list groups of a network"
  end

  def test_list_groups_when_logged_in
    login_as :red
    get :list_groups, :id => groups(:fai).name
    assert_response :success, "list groups of network fai should succeed, because user red in network rainbow"
  end


end
