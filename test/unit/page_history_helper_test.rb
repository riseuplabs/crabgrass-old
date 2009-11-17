require File.dirname(__FILE__) + '/../test_helper'

class PageHistoryHelperTest < Test::Unit::TestCase
  include PageHistoryHelper

  def setup
    @user = User.make :login => "pepe", :display_name => "Pepe le Piu"
    @user_a =  User.make(:display_name => "Kropotkin")
    User.current = @user 
    @page = Page.make_owned_by(:user => @user, :owner => @user, :access => 1)
    @group = Group.make(:full_name => "Insurrectos")
    @post = Post.build(:body => "Some nice comment", :user => @user, :page => @page).save!
  end

  def test_description_with_deleted_objects
    user_a = User.make :login => "user_a", :display_name => "User A"
    user_b = User.make :login => "user_b", :display_name => "User B"
    user_c = User.make :login => "user_c", :display_name => "User C"

    page_history = PageHistory::PageCreated.create!(:user => user_a, :page => @page)
    User.delete(user_a)
    description = "Unknown/Deleted has created the page"
    assert_equal description, description_for(page_history.reload)

    page_history = PageHistory::RevokedGroupAccess.create!(:user => user_b, :page => @page, :object => @group)
    User.delete(user_b)
    Group.delete(@group)
    description = "Unknown/Deleted revoked access to the group Unknown/Deleted"
    assert_equal description, description_for(page_history.reload)

    page_history = PageHistory::RevokedUserAccess.create!(:user => @user, :page => @page, :object => user_c)
    User.delete(user_c)
    description = "Pepe le Piu revoked access to the user Unknown/Deleted"
    assert_equal description, description_for(page_history.reload)
  end

  def test_description
    description = "Pepe le Piu has created the page"
    assert_equal description, description_for(PageHistory::PageCreated.create!(:user => @user, :page => @page))

    description = "Pepe le Piu has modified the page title"
    assert_equal description, description_for(PageHistory::ChangeTitle.create!(:user => @user, :page => @page))

    description = "Pepe le Piu has added a star"
    assert_equal description, description_for(PageHistory::AddStar.create!(:user => @user, :page => @page))

    description = "Pepe le Piu has removed a star"
    assert_equal description, description_for(PageHistory::RemoveStar.create!(:user => @user, :page => @page))

    description = "Pepe le Piu has made the page public"
    assert_equal description, description_for(PageHistory::MakePublic.create!(:user => @user, :page => @page))

    description = "Pepe le Piu has made unchecked the option to make the page public"
    assert_equal description, description_for(PageHistory::MakePrivate.create!(:user => @user, :page => @page))

    description = "Pepe le Piu has deleted the page"
    assert_equal description, description_for(PageHistory::Deleted.create!(:user => @user, :page => @page))

    description = "Pepe le Piu has started watching this page"
    assert_equal description, description_for(PageHistory::StartWatching.create!(:user => @user, :page => @page))

    description = "Pepe le Piu has stop watching this page"
    assert_equal description, description_for(PageHistory::StopWatching.create!(:user => @user, :page => @page))

    description = "Pepe le Piu has updated the page content"
    assert_equal description, description_for(PageHistory::UpdatedContent.create!(:user => @user, :page => @page))

    description = "Pepe le Piu granted full access to the group Insurrectos"
    assert_equal description, description_for(PageHistory::GrantGroupFullAccess.create!(:user => @user, :page => @page, :object => @group))

    description = "Pepe le Piu granted write access to the group Insurrectos"
    assert_equal description, description_for(PageHistory::GrantGroupWriteAccess.create!(:user => @user, :page => @page, :object => @group))

    description = "Pepe le Piu granted read access to the group Insurrectos"
    assert_equal description, description_for(PageHistory::GrantGroupReadAccess.create!(:user => @user, :page => @page, :object => @group))

    description = "Pepe le Piu revoked access to the group Insurrectos"
    assert_equal description, description_for(PageHistory::RevokedGroupAccess.create!(:user => @user, :page => @page, :object => @group))

    description = "Pepe le Piu granted full access to the user Kropotkin"
    assert_equal description, description_for(PageHistory::GrantUserFullAccess.create!(:user => @user, :page => @page, :object => @user_a))

    description = "Pepe le Piu granted write access to the user Kropotkin"
    assert_equal description, description_for(PageHistory::GrantUserWriteAccess.create!(:user => @user, :page => @page, :object => @user_a))

    description = "Pepe le Piu granted read access to the user Kropotkin"
    assert_equal description, description_for(PageHistory::GrantUserReadAccess.create!(:user => @user, :page => @page, :object => @user_a))

    description = "Pepe le Piu revoked access to the user Kropotkin"
    assert_equal description, description_for(PageHistory::RevokedUserAccess.create!(:user => @user, :page => @page, :object => @user_a))

    description = "Pepe le Piu added a comment"
    assert_equal description, description_for(PageHistory::AddComment.create!(:user => @user, :page => @page, :object => Post.last))

    description = "Pepe le Piu updated a comment"
    assert_equal description, description_for(PageHistory::UpdateComment.create!(:user => @user, :page => @page, :object => Post.last))

    description = "Pepe le Piu destroyed a comment"
    assert_equal description, description_for(PageHistory::DestroyComment.create!(:user => @user, :page => @page, :object => Post.last))
  end
end
