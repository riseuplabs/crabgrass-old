require File.dirname(__FILE__) + '/../test_helper'

class WikiTest < Test::Unit::TestCase

  def test_creations
    g = Group.create :name => 'robots'

    a = Tool::TextDoc.create :title => 'x61'
    a.add g; a.save

    b = Tool::TextDoc.new :title => 'x61'
    b.add g;
 
    assert_equal 'x61', a.name, 'name should equal title'
    assert b.name_taken?, 'name should already be taken'
    assert !b.valid?, 'should not be able to have two wikis with the same name'
  end
  
end
