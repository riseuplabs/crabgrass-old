require File.dirname(__FILE__) + '/../test_helper'

class TagTest < Test::Unit::TestCase
  fixtures :pages  
  def setup
    @obj = Page.find(:first)
    @obj.tag_with "pale imperial"
  end

  def test_to_s
    assert_equal "imperial pale", Page.find(:first).tags.to_s
  end
  
end
