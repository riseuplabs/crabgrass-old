require File.dirname(__FILE__) + '/../test_helper'

class MessageTest < Test::Unit::TestCase
  fixtures :users
  
  def test_creation
    to = [users(:blue), users(:green)]
    from = users(:red)
    page = Page.make :private_message, :to => to, :from => from,
      :title => 'hi there', :body => 'whatcha doing?'

    assert_equal 1, page.discussion.posts.size, 'there should be one post'
    assert page.discussion.posts.first.valid?, 'post should be valid (%s)' % page.discussion.posts.first.errors.full_messages.to_s
    assert page.discussion.valid?, 'discussion should be valid (%s)' % page.discussion.errors.full_messages.to_s
    assert page.valid?, 'page should be valid (%s)' % page.errors.full_messages.to_s
    
    page.save!
    
    page = Page.find(page.id)
    
    assert_equal 1, page.discussion.posts.size, 'there should be one post'
  end
end

