require File.dirname(__FILE__) + '/../../test_helper'
require 'keyring'

class StringTest < Test::Unit::TestCase
  def test_index_split
    str1 = "aZfox\nfoxCatfoxfoxCat"
    re1 = /(fox)|Z/
    
    str2 = "abcd"
    re2 = /Z/
    
    assert_equal ["a", "Z", "fox\n", "foxCat", "fox", "foxCat"], str1.index_split(re1)
    
    assert_equal ["abcd"], str2.index_split(re2)
  end
end