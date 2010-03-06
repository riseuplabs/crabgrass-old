require 'rubygems'
require 'test/unit'
require 'active_support'
require 'action_pack'
require 'action_controller'
require 'action_view'
require '../lib/partioprint'

class PartioprintTest < Test::Unit::TestCase
  
  def setup 
    path = "./fixtures"
    @view = ActionView::Base.new(path, {})
  end

  def test_render_partial_top
    str = "<!-- ERB:START partial: top_partial -->\nthis is top partial\n"+
    "<!-- ERB:START partial: inner_partial -->\nThis is second partial content.\n"+
    "<!-- ERB:END partial: inner_partial -->\n<!-- ERB:END partial: top_partial -->"
    assert_equal str, @view.render(:partial => "top_partial")
  end

  def test_render_partial_inner
    str = "<!-- ERB:START partial: inner_partial -->\n"+
    "This is second partial content.\n<!-- ERB:END partial: inner_partial -->"
    assert_equal str, @view.render(:partial => "inner_partial")
  end

  def test_with_nil_contents
    assert_nothing_raised { @view.render(:partial => "inner_partial", :collection => []) }
  end

end