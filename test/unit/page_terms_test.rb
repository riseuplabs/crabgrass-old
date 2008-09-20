require File.dirname(__FILE__) + '/../test_helper'

class PageTermsTest < Test::Unit::TestCase
  fixtures :users

  def setup
  end

  def test_create
    user = users(:blue)
    page = DiscussionPage.create! :title => 'hi', :user => user
    assert_equal Page.access_ids_for(:user_ids => [user.id]).first, page.page_terms.access_ids
  end
  
  protected
    
end
