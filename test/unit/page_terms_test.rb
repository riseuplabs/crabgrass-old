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

  def test_tagging_with_odd_characters
    name = 'test page'
    page = WikiPage.make :title => name.titleize, :name => name.nameize
    page.tag_list = "^&#, +, **, %, ə"
    page.save!

    "^&#, +, **, %, ə".split(', ').each do |char|
      found = Page.find_by_path(['tag', char]).first
      assert found, 'there should be a page tagged %s' % char
      assert_equal page.id, found.id, 'the page ids should match for tag %s' % char
    end
  end

  protected

end
