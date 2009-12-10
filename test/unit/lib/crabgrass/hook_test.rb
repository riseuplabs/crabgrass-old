# copied from:
# redmine - project management software
# Copyright (C) 2006-2008  Jean-Philippe Lang
# GPL v2 +

require File.dirname(__FILE__) + '/../../../test_helper'

class Crabgrass::Hook::ManagerTest < Test::Unit::TestCase

  # Some hooks that are manually registered in these tests
  class TestHook < Crabgrass::Hook::Listener; end

  class TestHook1 < TestHook
    def view_layouts_base_html_head(context)
      'Test hook 1 listener.'
    end
  end

  class TestHook2 < TestHook
    def view_layouts_base_html_head(context)
      'Test hook 2 listener.'
    end
  end

  class TestHook3 < TestHook
    def view_layouts_base_html_head(context)
      "Context keys: #{context.keys.collect(&:to_s).sort.join(', ')}."
    end
  end
  Crabgrass::Hook.clear_listeners

  def setup
    @hook_module = Crabgrass::Hook
  end

  def teardown
    @hook_module.clear_listeners
  end

  def test_clear_listeners
    assert_equal 0, @hook_module.hook_listeners(:view_layouts_base_html_head).size
    @hook_module.add_listener(TestHook1)
    @hook_module.add_listener(TestHook2)
    assert_equal 2, @hook_module.hook_listeners(:view_layouts_base_html_head).size

    @hook_module.clear_listeners
    assert_equal 0, @hook_module.hook_listeners(:view_layouts_base_html_head).size
  end

  def test_add_listener
    assert_equal 0, @hook_module.hook_listeners(:view_layouts_base_html_head).size
    @hook_module.add_listener(TestHook1)
    assert_equal 1, @hook_module.hook_listeners(:view_layouts_base_html_head).size
  end

  def test_call_hook
    @hook_module.add_listener(TestHook1)
    assert_equal 'Test hook 1 listener.', @hook_module.call_hook(:view_layouts_base_html_head)
  end

  def test_call_hook_with_context
    @hook_module.add_listener(TestHook3)
    assert_equal 'Context keys: bar, foo.', @hook_module.call_hook(:view_layouts_base_html_head, :foo => 1, :bar => 'a')
  end

  def test_call_hook_with_multiple_listeners
    @hook_module.add_listener(TestHook1)
    @hook_module.add_listener(TestHook2)
    assert_equal "Test hook 1 listener.\nTest hook 2 listener.", @hook_module.call_hook(:view_layouts_base_html_head)
  end
end
