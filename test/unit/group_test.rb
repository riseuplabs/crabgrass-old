require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < Test::Unit::TestCase
  fixtures :groups

  def test_truth
    assert true
  end
  
  def test_associations
    assert check_associations(Group)
  end
  
end
