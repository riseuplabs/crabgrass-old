require File.dirname(__FILE__) + '/../../test_helper'

class FindNotificationsTest < Test::Unit::TestCase
fixtures :users

  def test_find_for_views
    page = DiscussionPage.create! :title => 'classical sociologists', :public => true, :owner => users('blue')
    notice = "Blue was here"
    part = users('red').add_page page, {:notice => notice, :access => :view, :viewed => false}
    id = users('red').id
    page.save!
    part.save!

    pages = Page.find_by_path "/unread/#{id}"
    assert pages.any?
    assert_equal page.id, pages.first.id
    assert pages.first.respond_to? :notice
    assert_equal [notice], YAML.load(pages.first.notice)
  end

end
