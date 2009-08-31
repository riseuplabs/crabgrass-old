require File.dirname(__FILE__) + '/../../test_helper'

class BasePage::ShareControllerTest < ActionController::TestCase
  fixtures :users, :groups,
          :memberships, :user_participations, :group_participations,
          :pages, :profiles,
          :sites

  # tests that the share popup loads
  def test_show_share_popup
    login_as :blue
    xhr :post, :show, :name => 'share', :popup => true, :page_id => 1
    assert_response :success
    assert_raises Test::Unit::AssertionFailedError do
      assert_select 'input#share_with_everyone'
    end
  end

  # tests that the share popup loads
  def test_show_share_with_everyone
    with_site :unlimited do
      login_as :blue
      xhr :post, :show, :name => 'share', :popup => true, :page_id => 1
      assert_response :success
      assert_select 'input#share_with_everyone'
    end
  end

  # tests thate the notify popup loads
  def test_show_notify_popup
    login_as :blue
    xhr :post, :show, :name => 'notify', :page_id => 1, :popup => true
    assert_response :success
    assert_select 'div' # just so we check html syntax
  end


  # tests if it's possible to add recipients from the share popup
  def test_add_recipient
    login_as :blue

    # a request that should be successful
    xhr :post, :update, {:page_id =>  1, :recipient => {:name => 'penguin', :access => 'edit'}, :add => true }
    assert_response :success
    assert_select_rjs :insert, :top, 'share_page_recipient_table' do
      assert_select 'tr.unsaved'
      assert_select 'option[selected=selected][value=edit]', /Write/, 'new user should have edit access'
    end

    # this request should not end in adding the user a second time

    # a request that will not be successful, as the username doesn't exist.
    xhr :post, :update, {:page_id =>  1, :recipient => {:name => 'a_username_that_will_never_exist' }, :add => true }
    assert_failing_post

    # a request that should lead in an error because i may not pester that user
    user1 = users(:penguin)
    user2 = users(:yellow)
    login_as :penguin
    assert !user1.may_pester?(user2), 'user1 should not be allowed to pester user2'
    xhr :post, :update, { :page_id =>  1, :recipient => {:name => 'yellow' }, :add => true }
    assert_failing_post

  end

  def test_add_recipient_for_non_admins
    # if you don't have admin access, you should not be able to share, but you should be able to notify.
    page = Page.create!(:title=>'page')
    page.add(users(:kangaroo), :access => :edit)
    page.save

    login_as :kangaroo

    xhr :post, :update, { :page_id =>  page.id, :recipient => {:name => 'blue' }, :add => true }
    assert_failing_post

    page.add(users(:blue), :access => :view)
    page.save

    xhr :post, :notify, { :page_id =>  page.id, :recipient => {:name => 'blue' }, :add => true }
    assert_response :success
    assert_select_rjs :insert, :top, 'share_page_recipient_table' do
      assert_select 'td', /blue/
    end

    # lets make sure this also works when the recipient only has indirect access
    page.add(groups(:rainbow), :access => :edit)
    page.add(users(:red))
    page.save
    xhr :post, :notify, { :page_id =>  page.id, :recipient => {:name => 'red' }, :add => true }
    assert_response :success
    assert_select_rjs :insert, :top, 'share_page_recipient_table' do
      assert_select 'td', /red/
      assert_select 'td:nth-child(2)', /write/i
    end
  end

  # tests giving access to new or existing users or groups
  def test_add_access
    # setup user and page
    @page = Page.find(1)
    assert @page, 'page should exist (load the fixtures first, dumbass!!)'

    @user = User.find_by_login('red')
    assert @user, 'user should exist'
    assert @user.may?(:admin, @page), 'user should be able to admin page'

    login_as(:red)

    # get a public group without access to the page
    @group = Group.find_by_name('public_group_everyone_can_see')
    assert @group, 'group should exist'
    assert !@group.may?(:admin, @page), 'public group should not have access to page'

    # share the page with the group, and give admin-access to the group
    assert @user.may_pester?(@group), 'user should be able to pester pub group'
    assert_share_with(@page,@group,:admin)
    @page.reload
    assert @group.may?(:admin, @page), 'public group should have access to page'

    # get a private group. and try tp share with it
    @group_private = Group.find_by_name('private_group')
    assert @group_private, 'private group should exist'
    assert !@group_private.may?(:admin, @page), 'private group should not have access to page originally'

    xhr :post, :update, {:page_id => @page.id, :share => true, :recipients => { @group.name.to_sym => { :access => :admin } } }
    @page.reload
    assert !@group_private.may?(:admin, @page), 'private group should still not have access to page'

    # try to share with a user
    @recipient_user = users(:penguin)
    xhr :post, :update, {:page_id => @page.id, :share => true, :recipients => { @recipient_user.login.to_sym => { :access => :admin } } }
    @page.reload
    @recipient_user.reload
    assert @recipient_user.may?(:admin, @page), 'user penguin should have access to page'

    # when the page is already shared with a user, it should not be possible to add her again as a recipient
    xhr :post, :update, {:page_id => @page.id, :add => true, :recipient => {:name => @recipient_user.login } }
    assert_message(/already has access/)

    # try to share with a committe (#bugfixing a problem caused by the "+" in the committee name
    # 'warm' is the name of the fixture for rainbow+the-warm-colors
    @committee = groups(:"warm")
    assert @committee, 'committee rainbow+the-warm-colors should exist'
    #assert_share_with(@page,@committee,:admin)
  end

  def test_add_access_to_group_committee
    login_as :blue
    @page = groups(:rainbow).pages.find(:first)
    xhr :post, :update,
          :page_id => @page.id,
          :add => true,
          :recipient => {:name => "rainbow+the-cold-colors", :access => "admin"}

    assert_successful_post('add', 'should add the committe to the list of unsaved share items')
  end

  def test_add_access_to_user_with_existing_group_participation_that_affects_the_user
    # Scenarios with overlapping Group / UserParticipations

    login_as :red

    # 1. GroupParticipation with admin access exist. UserParticipation with admin access is requested
    @group = groups(:rainbow)
    @group_page = @group.pages.first
    @group_user = users(:purple)
    assert @group, 'group rainbow should exist'
    assert @group_user.member_of?(@group), 'the logged in user should be a member of this group (rainbow)'
    assert @group_user.member_of?(@group), 'user purple should be a member of this group (rainbow)'
    assert @group.may?(:admin, @group_page), 'the group should have full access to the page'
    assert !@group_page.users.include?(@group_user)

    # now we share the page with the user
    assert_share_with(@group_page,@group_user,:admin)
    assert UserParticipation.find_by_page_id_and_user_id(@group_page.id,@group_user.id), 'a user participation should now exist for the user'
    @group.reload
    assert @group.may?(:admin,@group_page), 'the group should still have :admin-access'
    assert @group_user.may?(:admin,@group_page), 'the user should still have :admin-acces'
  end

  # wtf is this?
  def test_something_else
    login_as :red

    # 2. GroupParticipation with :edit access exist. UserParticipation with admin access is requested
    # change the groups access to level :edit

    @group = groups(:rainbow)
    @group_page = @group.pages.first
    @group_user = users(:green)

    @user = users(:red)

    assert @user.may?(:admin,@group_page)

    assert_share_with(@group_page,@user,:admin)

    xhr :post, :update , {:page_id => @group_page.id, :recipients => { @group.name.to_sym => { :access => :edit } }, :share => true }

    @group.reload
    @group_page.reload
    assert !@group.may?(:admin,@group_page), 'the group should have admin access no longer'
    # we need a different group-user who has not yet a UserParticipation for this page
    @group_user = users(:purple)
    # the user should exist, be a member of rainbow, have :edit but no :admin access
    assert @group_user, 'user blue should exist'
    assert @group_user.member_of?(@group)
    assert !@group_page.users.include?(@group_user)
    assert @group_user.may?(:edit,@group_page)
    assert !@group_user.may?(:admin,@group_page)
    # grant admin access to this individual user who is also a member of the group
    assert_share_with(@group_page,@group_user,:admin)
    #raise @group_page.users.inspect
    @group_user.reload
    @group_page.reload
    #raise @group_page.users.inspect
    assert @group_user.may?(:admin,@group_page), 'the user should now have admin access to the group'
  end

  # test if sharing with and notifying a new user works
  def test_notification
    login_as :blue
    page = Page.find(1)
    user1 = User.find_by_login('blue')
    user2 = User.find_by_login('red')

    # assert that a UserParticipation for the User and Page already exists
    upart = UserParticipation.find_by_page_id_and_user_id(page.id, user2.id)
    assert upart, 'the userparticipation should already exist to notify the user'
    assert !upart.inbox,'participation.inbox flag should be false'

    # try to push the participation to inbox
    xhr :post, :notify, {:page_id => 1, :notify => "1", :recipients => { user2.login.to_sym => { :send_notice => 1} }, :notification => {:send_notice => "1", :send_message => 'additional_message'}, :recipient => {:access => 'admin'}}
    assert_response :success
    upart.reload
    assert upart.inbox, 'participation.inbox should be set to true now'
  end

  # test if notifying an existing user works
  def test_share_and_notify
    login_as :blue
    page = Page.find(1)

    user1 = users(:blue)
    user2 = users(:red)
    user3 = users(:orange)

    upart2 = UserParticipation.find_by_page_id_and_user_id(page.id, user2.id)
    assert upart2, 'a participation for this user should already exist'
    assert !upart2.inbox, 'the inbox flag for this participation should be set to false'

    # assert that there is no existing user_participation for the page and the user yet
    upart3 = UserParticipation.find_by_page_id_and_user_id(page.id, user3.id)
    assert !upart3, 'this user_participation should not yet exist'

    # try to push the participation to inbox
    assert_difference 'UserParticipation.count' do
      xhr :post, :update, {:page_id => 1, :share => true, :recipients => {user3.login.to_sym => {:access => 'admin'}, user2.login.to_sym => {:access => 'admin'} }, :notification => { :send_notice => "1", :send_message => 'additional_message'}}
      assert_response :success
      upart = UserParticipation.find_by_page_id_and_user_id(page.id, user3.id)
      assert upart, 'a participation for this user should exist now'
      assert upart.inbox, 'participation.inbox should be set to true now'
      assert upart2.reload.inbox, 'participation.inbox should be set to true now'
    end

  end

  def test_notify_group
    login_as :blue

    page = DiscussionPage.create! :title => 'dup', :user => users(:blue), :owner => users(:blue), :share_with => 'rainbow', :access => :admin

    xhr :post, :notify, {:page_id => page.id, "notify"=>true, "notification"=>{"send_notice"=>"1", "send_message"=>"", "send_email"=>"0"}, "action"=>"notify", "recipients"=>{"rainbow"=>{"send_notice"=>"1"}}, "controller"=>"base_page/share"}

    page.reload
    group_users = groups(:rainbow).users.collect{|u|u.name}.sort
    page_users = page.user_participations.collect{|up|up.user.name}.sort
    assert_equal group_users, page_users
  end

  private

  # asserts both, adding the recipient to the recipient list, and then actually sharing the page
  def assert_share_with(page,recipient,access=:admin,success=true)
    flash = nil
    # get the right name for the recipient (either name or login)
    recipient_name = recipient.kind_of?(Group) ? recipient.name : recipient.login
    # first add the recipient to the recipients list...
    xhr :post, :update, {:page_id =>  page.id, :add => true, :recipient => {:name => recipient_name.gsub(/\+/,'%2B') } }
    # success ? assert_not_nil(assigns(:recipient)) : assert(!assigns(:recipient))

    success ? assert_successful_post('add') : assert_failing_post

    # then actually share
    xhr :post, :update , { :page_id => page.id, :recipients => { recipient_name.to_sym => { :access => access } }, :share => true }
    success ? assert_successful_post : assert_failing_post
  end


  # asserts that the last called request was answered with success, and the response includes a notice-div
  def assert_successful_post(update='share', message=nil)
    assert_response :success
    if update == 'add'
      assert_not_nil assigns(:recipients)
      assert_select 'tr.unsaved', nil, message
    else
      assert_select 'div.small_notice', nil, message
    end
  end

  # asserts that the last called request was answered with success, and the response includes an error-div
  def assert_failing_post
    assert_error_message
  end

end
