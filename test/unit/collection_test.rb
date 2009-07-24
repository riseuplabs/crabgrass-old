require File.dirname(__FILE__) + '/../test_helper'

class CollectionTest < Test::Unit::TestCase
  #fixtures :users, :pages

=begin

  DISABLED FOR NOW, SINCE WE DON'T HAVE A NEED FOR THIS YET

  def test_add_and_remove
    coll = Collection.create! :title => 'kites'
    p1 = Page.find 1
    p2 = Page.find 2

    assert_nothing_raised do
      coll.add_child!(p1)
      coll.add_child!(p2)
    end

    # note: oddly, coll.children.include?() fails,
    # but coll.child_pages.include?() and coll.child_ids.include?()
    # both work.

    assert coll.child_ids.include?(p1.id)
    assert coll.child_ids.include?(p2.id)
    assert p1.parents.include?(coll)
    assert p2.parents.include?(coll)

    assert_nothing_raised do
      coll.remove_child!(p1)
      coll.remove_child!(p2)
    end

    assert !coll.child_ids.include?(p1.id)
    assert !coll.child_ids.include?(p2.id)
    assert !p1.parents.include?(coll)
    assert !p2.parents.include?(coll)
  end

  def test_position
    coll = Collection.create! :title => 'kites'
    Page.find(:all, :limit => 5).each do |page|
      coll.add_child!(page)
    end

    positions = coll.children.collect{|page| page.id}
    correct_new_positions = [positions.pop] + positions # move the last to the front

    coll.links.last.move_to_top

    new_positions = coll.children(true).collect{|page| page.id}
    assert_equal correct_new_positions, new_positions
  end


  def test_add_before_save
    coll = Collection.create! :title => 'kites'
    page = DiscussionPage.new :title => 'hi', :collection_id => coll.id
    assert page.new_record?
    assert page.save
    assert !page.new_record?
    assert coll.child_pages(true).include?(page)
  end

  def test_associations
    assert check_associations(Link)
    assert check_associations(Collection)
  end
=end

end
