require File.dirname(__FILE__) + '/../test_helper'

class MenuItemTest < ActiveSupport::TestCase

  fixtures :groups, :menu_items, :users, :profiles, :widgets

  def test_group_menu_bar_items
    profile = groups(:fai).profiles.public
    widget = profile.widgets.find_by_name 'MenuBarWidget'
    assert_not_nil menu_items = widget.menu_items
    assert_equal 5, menu_items.count, 'there should be 5 menu items for the first site.'
    menu_items.each_with_index do |m,i|
      assert_equal i, m.position, 'menu_items should be returned in the order of positions.'
      assert_equal widget.id, m.widget_id, 'all menu items should belong to the widget.'
    end
  end
end
