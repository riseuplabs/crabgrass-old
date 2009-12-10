require File.dirname(__FILE__) + '/../test_helper'

class LanguageTest < ActiveSupport::TestCase
  fixtures :languages, :translations, :keys

  def test_mixin_is_working
    assert Language.default.percent_complete
  end
end
