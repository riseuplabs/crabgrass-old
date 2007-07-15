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

  # can we build up a new page, new discussion, and new posts
  # all in memory and then have them saved all at once?
  def test_building
    @page =     Page.new(:title => 'my page')
    @discussion = Discussion.new
    @page.discussion = @discussion
    @discussion.page = @page
    
    @post = Post.new(:body => 'hi')
    @discussion.posts << @post
    @post.discussion = @discussion
    @post.user = users(:blue)
   
    @page.save
    
    assert @page.discussion.posts.any?, 'page should have posts' 
    assert @post.valid?, 'post should be valid (%s)' % @post.errors.full_messages.to_s
    assert @discussion.valid?, 'discussion should be valid (%s)' % @discussion.errors.full_messages.to_s
  end


  def test_associations
    assert check_associations(Post)
  end

end
