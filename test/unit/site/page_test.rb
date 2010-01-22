require File.dirname(__FILE__) + '/../../test_helper'

class PageTest < Test::Unit::TestCase
  fixtures :pages, :sites, :page_terms

  def test_sites
    # create the page
    # site = sites(:limited)
    with_site(:limited) do |site|
      page = DiscussionPage.create! :title => 'page in site'
      assert_equal site.id, page.site_id, 'should auto set site id'

      # find for site :limited
      pages = Page.find_by_path('', :site_ids => [site.id])
      assert_equal 1, pages.size, 'should return exactly on page'
      assert_equal page.id, pages.first.id, 'should return page just created'
    end
    # not in site :redwood
    # site = sites(:redwood)
    with_site(:redwood) do |site|
      pages = Page.find_by_path('', :site_ids => [site.id])
      assert_equal 0, pages.size, 'should not find any pages for other site'
    end
  end

  protected

end
