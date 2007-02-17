require File.dirname(__FILE__) + '/../test_helper'

class PageMakeTest < Test::Unit::TestCase

  fixtures :pages, :users, :groups

  def setup
    #@page = create_page :title => 'this is a very fine test page'
    # @page_tool_count = @page.tools.length
  end

  def test_request_to_join_group
    u = users(:kangaroo)
    g = groups(:rainbow)
    page = Page.make :request_to_join_group, :user => u, :group => g
    page.save # required for associations to be available
    
    assert_equal Poll::Request, page.tool.class
    assert_equal Actions::AddToGroup, page.tool.possible.action.class
    assert g.pages.include?(page),'group must have new page'
    assert page.groups.include?(g),'page must have new group'
    
  end

  protected
    def create_page(options = {})
      defaults = {:title => 'untitled page', :public => false}
      Page.create(defaults.merge(options))
    end
end
