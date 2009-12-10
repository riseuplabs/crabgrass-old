require File.dirname(__FILE__) + '/../test_helper'

class MenuItemTest < ActiveSupport::TestCase

  fixtures :groups, :menu_items, :users

  def test_group_menu_items
    group = groups(:fai)
    assert_not_nil menu_items = group.menu_items
    assert_equal 5, menu_items.count, 'there should be 5 menu items for the first group.'
    menu_items.each_with_index do |m,i|
      assert_equal i, m.position, 'menu_items should be returned in the order of positions.'
      assert_equal group.id, m.group_id, 'all menu items should belong to the group.'
    end
  end
end
