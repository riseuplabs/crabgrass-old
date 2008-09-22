require 'test/unit'
require File.dirname(__FILE__) + '/../../../test/test_helper'

class GalleryToolTest < Test::Unit::TestCase
  fixtures :users, :pages, :assets

  def test_add_and_remove
    gal = Gallery.create! :title => 'kites'
    a1 = Asset.find 1
    a2 = Asset.find 2

    assert_nothing_raised do
      gal.add_image!(a1)
      gal.add_image!(a2)
    end

    assert gal.images.include?(a1)
    assert gal.images.include?(a2)
    assert a1.galleries.include?(gal)
    assert a2.galleries.include?(gal)

    assert_nothing_raised do
      gal.remove_image!(a1)
      gal.remove_image!(a2)
    end

    assert !gal.images.include?(a1)
    assert !gal.images.include?(a2)
    assert !a1.galleries.include?(gal)
    assert !a2.galleries.include?(gal)
  end

  def test_position
    gal = Gallery.create! :title => 'kites'
    Asset.media_type(:image).find(:all, :limit => 3).each do |asset|
      gal.add_image!(asset)
    end

    positions = gal.images.collect{|image| image.id}
    correct_new_positions = [positions.pop] + positions # move the last to the front

    gal.showings.last.move_to_top

    new_positions = gal.images(true).collect{|image| image.id}
    assert_equal correct_new_positions, new_positions    
  end

  #def test_add_before_save
  #  coll = Collection.create! :title => 'kites'
  #  page = DiscussionPage.new :title => 'hi', :collection_id => coll.id
  #  assert page.new_record?
  #  assert page.save
  #  assert !page.new_record?
  #  assert coll.child_pages(true).include?(page)
  #end

  def test_associations
    assert check_associations(Gallery)
    assert check_associations(Showing)
  end  

end
