require File.dirname(__FILE__) + '/../test_helper'

class PageHistoryTest < Test::Unit::TestCase

  def setup
    @pepe = User.make :login => "pepe"
    User.current = @pepe
    @page = Page.make_owned_by(:user => @pepe, :owner => @pepe, :access => 1)
    @last_count = @page.page_history.count
  end

  def test_validations
    assert_raise ActiveRecord::RecordInvalid do PageHistory.create!(:user => nil, :page => nil) end
    assert_raise ActiveRecord::RecordInvalid do PageHistory.create!(:user => @pepe, :page => nil) end
    assert_raise ActiveRecord::RecordInvalid do PageHistory.create!(:user => nil, :page => @page) end
  end

  def test_associations
    page_history = PageHistory.create!(:user => @pepe, :page => @page)
    assert_equal @pepe, page_history.user
    assert_kind_of Page, page_history.page
    assert_equal @page.page_history.last, PageHistory.last
  end
end
