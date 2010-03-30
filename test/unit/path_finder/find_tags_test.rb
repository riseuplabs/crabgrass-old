require File.dirname(__FILE__) + '/../../test_helper'

class FindTagsTest < ActiveSupport::TestCase

  def test_find_with_spaces
    page = DiscussionPage.create! :title => 'classical sociologists', :public => true
    page.tag_list = 'max weber, emile durkheim, karl marx'
    page.save!

    pages = Page.find_by_path '/tag/max weber'
    assert pages.any?
    assert_equal page.id, pages.first.id

    pages = Page.find_by_path '/tag/emile+durkheim'
    assert pages.any?
    assert_equal page.id, pages.first.id
  end

end
