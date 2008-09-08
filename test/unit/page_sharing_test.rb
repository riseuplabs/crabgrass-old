require File.dirname(__FILE__) + '/../test_helper'

class PageSharingTest < Test::Unit::TestCase

  fixtures :pages, :users, :groups, :memberships

  def setup
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
  
  protected
  
  def create_page(options = {})
    defaults = {:title => 'untitled page', :public => false}
    Page.create(defaults.merge(options))
  end
  
end
