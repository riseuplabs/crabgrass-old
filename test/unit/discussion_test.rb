require File.dirname(__FILE__) + '/../test_helper'

class DiscussionTest < ActiveSupport::TestCase
  fixtures :users, :pages

  def test_creation
    discussion = Discussion.create
    post       = discussion.posts.create(:body => 'hi', :user => users(:blue))
    assert post.valid?, 'post should be valid (%s)' % post.errors.full_messages.to_s
    assert discussion.valid?, 'discussion should be valid (%s)' % discussion.errors.full_messages.to_s

    post       = discussion.posts.create(:body => 'hi', :user => users(:blue))
    assert 2, discussion.reload.posts_count
  end

  # can we build up a new page, new discussion, and new posts
  # all in memory and then have them saved all at once?
  def test_building
    discussion = Discussion.create!
    post = discussion.posts.build(:user => users(:blue), :body => 'hi')
    assert_nothing_raised do
      post.save!
    end

    discussion.posts.inspect
    ## ^^^ without this line, the next assertion fails. WTF!!!!
    assert_equal 1, discussion.posts.size

    discussion.reload
    assert_equal post, discussion.last_post
  end

  def test_with_page
    page = Page.find 1
    user = users(:red)

    post = Post.build(:page => page, :user => user, :body => 'hi')
    assert_nothing_raised do
      post.save!
    end
    post = Post.build(:page => page, :user => user, :body => 'hi')
    assert_nothing_raised do
      post.save!
    end
    assert_equal 2, page.discussion.reload.posts_count
    assert_equal 2, page.discussion.posts.size

    page.save!

    assert_equal 2, page.reload.posts_count
    assert_equal user, page.discussion.replied_by
    assert_equal post, page.discussion.last_post
  end

  def test_associations
    assert check_associations(Post)
    assert check_associations(Discussion)
  end

  def test_discussion_update
    discussion = Discussion.create
    post1      = discussion.posts.create(:body => 'hi', :user => users(:blue))
    post2      = discussion.posts.create(:body => 'hello', :user => users(:red))
    assert_equal 2, discussion.reload.posts_count
    assert_last_post_properties post2, discussion
    post2.delete
    assert_equal 1, discussion.reload.posts_count
    assert_last_post_properties post1, discussion
    post2.undelete
    assert_equal 2, discussion.reload.posts_count
    assert_last_post_properties post2, discussion
    post2.destroy
    assert_equal 1, discussion.reload.posts_count
    assert_last_post_properties post1, discussion
    post1.delete
    assert_equal 0, discussion.reload.posts_count
    assert_last_post_properties nil, discussion
    post1.destroy
    assert_equal 0, discussion.reload.posts_count
    assert_last_post_properties nil, discussion
  end

  def assert_last_post_properties(post, discussion)
    if post.nil?
      assert discussion.last_post.nil?
      assert discussion.replied_at.nil?
      assert discussion.replied_by.nil?
      return
    end
    assert_equal post, discussion.last_post
    assert post.updated_at - discussion.replied_at < 1
    assert post.updated_at > discussion.replied_at
    assert_equal post.user, discussion.replied_by
  end


end
