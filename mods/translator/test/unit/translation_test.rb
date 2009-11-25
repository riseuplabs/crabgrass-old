require File.dirname(__FILE__) + '/../test_helper'

class TranslationTest < ActiveSupport::TestCase
#  fixtures :keys

#  def test_validations
#    trans = Translation.new valid_translation
#    assert trans.save, "should save valid translation"
#
#    trans = Translation.new valid_translation.merge(:key => nil)
#    assert !trans.save, "translation should require a key"
#
#    trans = Translation.new valid_translation.merge(:language => nil)
#    assert !trans.save, "translation should require a language"
#
#    trans = Translation.new valid_translation.merge(:user => nil)
#    assert !trans.save, "translation should require a user"
#
#    trans = Translation.new valid_translation.merge(:text => nil)
#    assert !trans.save, "translation should require some text"
#  end

#  def test_best_guess
#    assert_equal "Hello", Translation.best_guess(keys(:hello), languages(:english))
#  end

#  def test_wanted_from
#    assert_equal Translation, Translation.wanted_from(users(:abie)).class
#  end
end
