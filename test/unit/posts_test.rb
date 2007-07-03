require File.dirname(__FILE__) + '/../test_helper'

class PostsTest < Test::Unit::TestCase
  fixtures :users
  
  def test_creation
    @page = Page.create(:title => 'my page')
    @discussion = @page.discussion ||= Discussion.create
    @post       = @discussion.posts.build(:body => 'hi')
    @post.user = users(:blue)
    @post.save
    assert @post.valid?, 'post should be valid (%s)' % @post.errors.full_messages.to_s
    assert @discussion.valid?, 'discussion should be valid (%s)' % @discussion.errors.full_messages.to_s
  end

  def test_associations
    assert check_associations(Post)
  end

end
