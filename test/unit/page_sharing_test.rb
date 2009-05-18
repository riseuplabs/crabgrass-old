require File.dirname(__FILE__) + '/../test_helper'

class PageSharingTest < Test::Unit::TestCase

  fixtures :pages, :users, :groups, :memberships, :user_participations

  def setup
  end

  def test_group_sharing_takes_precedence
    creator = users(:kangaroo)
    red = users(:red)
    rainbow = groups(:rainbow)

    page = Page.create(:title => 'a very popular page', :user => creator)
    assert page.valid?, 'page should be valid: %s' % page.errors.full_messages.to_s

    assert creator.may?(:admin, page), 'creator should be able to admin page'
    assert_equal false, red.may?(:view, page), 'user red should not see the page'

    # share with user
    creator.share_page_with!(page, "red", :message => "hi red", :grant_access => :view)
    assert_equal true, red.may?(:view, page), 'user red should see the page'
    assert_equal false, red.may?(:edit, page), 'user red should not be able to edit the page'

    # share with group
    creator.share_page_with!(page, "rainbow", :message => "hi rainbow", :grant_access => :edit)
    assert_equal true, red.may?(:edit, page), 'user red should be able to edit the page'
    assert_equal true, rainbow.may?(:edit, page), 'group rainbow should be able to edit the page'
  end

  def test_share_page_with_owner
    user = users(:kangaroo)
    group = groups(:animals)
    
    page = Page.create(:title => 'fun fun', :user => user, :share_with => group, :access => :admin)
    assert page.valid?, 'page should be valid: %s' % page.errors.full_messages.to_s
    assert group.may?(:admin, page), 'group be able to admin group'

    assert_nothing_raised do 
      user.share_page_with!(page, "animals", :message => 'hey you', :grant_access => :view)
    end

    assert group.may?(:admin, page), 'group should still be able to admin group'
  end

  def test_share_with_view_access
    user = users(:kangaroo)
    other_user = users(:dolphin)
    group = groups(:animals)
    recipients = [group]
    page = Page.create!(:title => 'an unkindness of ravens', :user => user, :share_with => recipients, :access => :view)

    #user.share_page_with!(page, recipients, :access => :view)

    assert group.may?(:view, page), 'group must have view access'
    assert !group.may?(:admin, page), 'group must not have admin access'   
  end

  def test_share_inbox_rules
    user       = users(:kangaroo)
    other_user = users(:dolphin)
    group      = groups(:animals)
    other_group = groups(:rainbow)
    user_in_other_group = users(:red)
    assert user_in_other_group.member_of?(other_group)
    assert !user_in_other_group.member_of?(group)

    page = Page.create!(:title => 'an unkindness of ravens', :user => user, :share_with => group, :access => :view)

    assert_nil page.user_participations.find_by_user_id(other_user.id), 'just adding access should not create a user participation record for users in the group'
    
    user.share_page_with!(page, other_user, :access => :admin, :send_notice => true)
    assert_equal true, page.user_participations.find_by_user_id(other_user.id).inbox?, 'should be in other users inbox'
    assert_equal false, page.user_participations.find_by_user_id(other_user.id).viewed?, 'should be marked unread'
    assert_equal true, other_user.may?(:admin, page), 'should have admin access'

    assert_nil page.user_participations.find_by_user_id(user_in_other_group.id)
    user.share_page_with!(page, other_group, :access => :view)
    page.save!
    assert user_in_other_group.may?(:view, page)
    assert_nil page.user_participations.find_by_user_id(user_in_other_group.id)

    user.share_page_with!(page, other_group, :send_notice => true)
    page.save!
    assert_not_nil page.user_participations.find_by_user_id(user_in_other_group.id)
    assert_equal true, page.user_participations.find_by_user_id(user_in_other_group.id).inbox?
    assert_equal false, page.user_participations.find_by_user_id(user_in_other_group.id).viewed?, 'should be marked unread'
  end

  def test_add_page
    user = users(:kangaroo)
    page = nil
    assert_nothing_raised do
      page = Page.create!(:title => 'fun fun')
    end

    page.add(user, :access => :edit)
    
    # sadly, page.users is not updated yet.    
    assert !page.users.include?(user), 'it would be nice if we could do this'

    assert_nothing_raised do
      page.save!
    end
    assert page.users.include?(user), 'page.users should be updated'

    assert_raises PermissionDenied do 
      user.may!(:admin, page)
    end 
  end
  
  def test_page_update
    page = pages(:wiki)
    user = users(:blue)
    page.add(user, :access => :admin)
    page.save!

    assert page.user_participations.size > 1
    page.user_participations.each do |up|
      up.update_attribute(:viewed, true)
    end

    user.updated(page)

    page = Page.find(page.id)
    page.user_participations.each do |up|
      assert_equal(false, up.viewed, 'should not be viewed') unless up.user == user
    end
  end

  def test_share_hash
    user = users(:kangaroo)
    group = groups(:animals)
    user2 = users(:red)
 
    page = Page.create(:title => 'x', :user => user, :access => :admin)
    user.share_page_with!(page, {:animals => {:access => "edit"}, :red => {:access => "edit"}}, {})

    assert group.may?(:edit, page)
    assert !group.may?(:admin, page)
    assert user2.may?(:edit, page)
    assert !user2.may?(:admin, page)
  end

  protected
  
  def create_page(options = {})
    defaults = {:title => 'untitled page', :public => false}
    Page.create(defaults.merge(options))
  end
  
end
