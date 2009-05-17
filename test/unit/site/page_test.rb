require File.dirname(__FILE__) + '/../../test_helper'

class PageTest < Test::Unit::TestCase

  fixtures :pages, :sites, :page_terms

  def setup
  end

  def teardown
    disable_site_testing
  end

  def test_sites
    # create the page
    site = sites(:limited)
    enable_site_testing(:limited)
    page = DiscussionPage.create! :title => 'page in site'
    assert_equal site.id, page.site_id, 'should auto set site id'

    # find for site :limited
    pages = Page.find_by_path('', :site_ids => [site.id])
    assert_equal 1, pages.size, 'should return exactly on page'
    assert_equal page.id, pages.first.id, 'should return page just created'

    # not in site :redwood
    site = sites(:redwood)
    enable_site_testing(:redwood)
    pages = Page.find_by_path('', :site_ids => [site.id])
    assert_equal 0, pages.size, 'should not find any pages for other site'
  end

  protected
  
end
