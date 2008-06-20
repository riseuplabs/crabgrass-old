require File.dirname(__FILE__) + '/../test_helper'

class TaggingTest < Test::Unit::TestCase
  fixtures :pages
  def setup
    @objs = Page.find(:all, :limit => 2)
    
    @obj1 = @objs[0]
    @obj1.tag_list = "pale"
    @obj1.save
    
    @obj2 = @objs[1]
    @obj2.tag_list = "pale, imperial"
    @obj2.save
  end

  def test_tag_list
    @obj2.tag_list = "hoppy, pilsner"
    assert_equal ["hoppy", "pilsner"], @obj2.tag_list
  end
  
  def test_find_tagged_with
    @obj1.tag_list = "seasonal, lager, ipa"
    @obj1.save
    @obj2.tag_list = "lager, stout, fruity, seasonal"
    @obj2.save
    
    result1 = [@obj1]
    assert_equal Page.find_tagged_with("ipa", :on => :tags), result1
    
    result2 = [@obj1.id, @obj2.id].sort
    assert_equal result2, Page.find_tagged_with("seasonal", :on => :tags).map(&:id).sort
    assert_equal result2, Page.find_tagged_with(["seasonal", "lager"], :on => :tags).map(&:id).sort
  end
    
end
