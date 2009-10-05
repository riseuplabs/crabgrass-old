require File.dirname(__FILE__) + '/../test_helper'

class PageTrackingObserverTest < Test::Unit::TestCase

  def setup
    @pepe = User.make :login => "pepe"
    @manu = User.make :login => "manu"
    User.current = @pepe
    @page = Page.make_owned_by(:user => @pepe, :owner => @pepe, :access => 1)
    @last_count = @page.page_history.count
  end

  def test_save_page_without_modifications
    @page.save!
    assert_equal @last_count, @page.page_history.count
  end

  def test_change_page_title
    @page.title = "Other title"
    @page.save!
    assert_equal @last_count + 1, @page.page_history.count
    assert_equal @pepe, @page.page_history.last.user
    assert_equal PageHistory::ChangeTitle, @page.page_history.last.class
  end

  def test_add_star
    @upart = @page.add(@pepe, :star => true ).save!
    @page.reload
    assert_equal @last_count + 1, @page.page_history.count
    assert_equal @pepe, @page.page_history.last.user
    assert_equal PageHistory::AddStar, @page.page_history.last.class
  end

  def test_remove_star
    @upart = @page.add(@pepe, :star => true).save!
    @upart = @page.add(@pepe, :star => nil).save!
    @page.reload
    assert_equal @last_count + 2, @page.page_history.count
    assert_equal @pepe, @page.page_history.last.user
    assert_equal PageHistory::RemoveStar, @page.page_history.last.class
  end  

  def test_mark_as_public
    @page.public = true
    @page.save
    assert_equal @last_count + 1, @page.page_history.count
    assert_equal @pepe, @page.page_history.last.user
    assert_equal PageHistory::MakePublic, @page.page_history.last.class
  end

  def test_mark_as_private
    @page.public = false
    @page.save
    assert_equal @last_count + 1, @page.page_history.count
    assert_equal @pepe, @page.page_history.last.user
    assert_equal PageHistory::MakePrivate, @page.page_history.last.class
  end

  def test_page_deleted
    @page.delete
    assert_equal @last_count + 1, @page.page_history.count
    assert_equal @pepe, @page.page_history.last.user
    assert_equal PageHistory::Deleted, @page.page_history.last.class
  end

  def test_add_tag
    true
  end

  def test_remove_tag
    true
  end

  def test_add_attachment
    true
  end

  def test_remove_attachment
    true
  end

  def test_start_watching
    @upart = @page.add(@pepe, :watch => true).save!
    @page.reload
    assert_equal @last_count + 1, @page.page_history.count
    assert_equal @pepe, @page.page_history.last.user
    assert_equal PageHistory::StartWatching, @page.page_history.last.class
  end

  def test_stop_watching
    @upart = @page.add(@pepe, :watch => true).save!
    @page.reload
    @upart = @page.add(@pepe, :watch => nil).save!
    @page.reload
    assert_equal @last_count + 2, @page.page_history.count
    assert_equal @pepe, @page.page_history.last.user
    assert_equal PageHistory::StopWatching, @page.page_history.last.class
  end

  def test_share_page_with_user_assigning_full_access
    @pepe.share_page_with!(@page, [@manu.login], {:access => 1})
    assert_equal @last_count + 1, @page.page_history.count
    assert_equal @pepe, @page.page_history.last.user
    assert_equal PageHistory::GrantUserFullAccess, @page.page_history.last.class
    assert_equal User, @page.page_history.last.object.class
  end

  def test_share_page_with_user_assigning_write_access
    @pepe.share_page_with!(@page, [@manu.login], {:access => 2})
    assert_equal @last_count + 1, @page.page_history.count
    assert_equal @pepe, @page.page_history.last.user
    assert_equal PageHistory::GrantUserWriteAccess, @page.page_history.last.class
    assert_equal User, @page.page_history.last.object.class
  end

  def test_share_page_with_user_assigning_read_access
    @pepe.share_page_with!(@page, [@manu.login], {:access => 3})
    assert_equal @last_count + 1, @page.page_history.count
    assert_equal @pepe, @page.page_history.last.user
    assert_equal PageHistory::GrantUserReadAccess, @page.page_history.last.class
    assert_equal User, @page.page_history.last.object.class
  end

  def test_share_page_with_user_removing_access
    @pepe.share_page_with!(@page, [@manu.login], {:access => 3})
    @page.user_participations.last.destroy
    assert_equal @last_count + 2, @page.page_history.count
    assert_equal @pepe, @page.page_history.last.user
    assert_equal PageHistory::RevokedUserAccess, @page.page_history.last.class
    assert_equal User, @page.page_history.last.object.class
  end

  def test_share_page_with_group_assigning_full_access
    @pepe.share_page_with!(@page, Group.make_owned_by(:user => @pepe), :access => 1)
    assert_equal @last_count + 1, @page.page_history.count
    assert_equal @pepe, @page.page_history.last.user
    assert_equal PageHistory::GrantGroupFullAccess, @page.page_history.last.class
    assert_equal Group, @page.page_history.last.object.class
  end

  def test_share_page_with_group_assigning_write_access
    @pepe.share_page_with!(@page, Group.make_owned_by(:user => @pepe), :access => 2)
    assert_equal @last_count + 1, @page.page_history.count
    assert_equal @pepe, @page.page_history.last.user
    assert_equal PageHistory::GrantGroupWriteAccess, @page.page_history.last.class
    assert_equal Group, @page.page_history.last.object.class
  end

  def test_share_page_with_group_assigning_read_access
    @pepe.share_page_with!(@page, Group.make_owned_by(:user => @pepe), :access => 3)
    assert_equal @last_count + 1, @page.page_history.count
    assert_equal @pepe, @page.page_history.last.user
    assert_equal PageHistory::GrantGroupReadAccess, @page.page_history.last.class
    assert_equal Group, @page.page_history.last.object.class
  end

  def test_share_page_with_group_removing_access
    @pepe.share_page_with!(@page, Group.make_owned_by(:user => @pepe), :access => 3)
    @page.group_participations.last.destroy
    assert_equal @last_count + 2, @page.page_history.count
    assert_equal @pepe, @page.page_history.last.user
    assert_equal PageHistory::RevokedGroupAccess, @page.page_history.last.class
    assert_equal Group, @page.page_history.last.object.class
  end

  def test_update_content
    page = Page.make(:data => Wiki.new(:user => @pepe, :body => ""))
    wiki = Wiki.find page.data_id
    previous_page_history = page.page_history.count
    wiki.update_section!(:document, @pepe, 1, "dsds")
    assert_equal PageHistory::UpdatedContent, page.page_history.last.class
    assert_equal previous_page_history + 1, page.page_history.count 
    assert_equal @pepe, page.page_history.last.user
  end

  def test_add_comment
    Post.build(:body => "Some nice comment", :user => @pepe, :page => @page).save!
    assert_equal @last_count + 1, @page.page_history.count
    assert_equal @pepe, @page.page_history.last.user
    assert_equal PageHistory::AddComment, @page.page_history.last.class
    assert_equal Post, @page.page_history.last.object.class
    assert_equal Post.last, @page.page_history.last.object
  end

  def test_edit_comment
    Post.build(:body => "Some nice comment", :user => @pepe, :page => @page).save!
    @post = Post.last
    @post.update_attribute("body", "Some nice comment, congrats!")
    assert_equal @last_count + 2, @page.page_history.count
    assert_equal @pepe, @page.page_history.last.user
    assert_equal PageHistory::UpdateComment, @page.page_history.last.class
    assert_equal Post, @page.page_history.last.object.class
    assert_equal Post.last, @page.page_history.last.object
  end

  def test_delete_comment
    Post.build(:body => "Some nice comment", :user => @pepe, :page => @page).save!
    @post = Post.last
    @post.destroy
    assert_equal @last_count + 2, @page.page_history.count
    assert_equal @pepe, @page.page_history.last.user
    assert_equal PageHistory::DestroyComment, @page.page_history.last.class
  end

  def test_page_destroyed
    # hmm we need to figure out another way to store this action
    # to be notified since when the page record is destroyed all
    # hisotries are destroyed too
    true
  end

end
