require File.dirname(__FILE__) + '/../test_helper'

class LanguageTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_all
    assert_equal Language.find(:all), Language.all
  end
end
