require 'rubygems'
require 'test/unit'
require 'active_support'
require 'action_pack'
require 'action_controller'
require 'action_view'

Dir[File.dirname(__FILE__) + "/../lib/*.rb"].each do |file|
  require file
end

class PartioprintTest < Test::Unit::TestCase

  def setup 
    path = "./fixtures"
    @view = ActionView::Base.new(path, {})
    ActionView::Partials.partioprint_decorators =  [PartioPrinter]
  end

  def test_render_partial_top
    str = "<!-- ERB:START partial: top_partial AND partial_absolute_path: ./fixtures/_top_partial.erb -->\n"+
    "this is top partial\n"+
    "<!-- ERB:START partial: inner_partial AND partial_absolute_path: ./fixtures/_inner_partial.erb -->\n"+
    "This is second partial content.\n"+
    "<!-- ERB:END partial: inner_partial AND partial_absolute_path: ./fixtures/_inner_partial.erb -->\n"+
    "<!-- ERB:END partial: top_partial AND partial_absolute_path: ./fixtures/_top_partial.erb -->"
    assert_equal str, @view.render(:partial => "top_partial")
  end

  def test_render_partial_inner
    str = "<!-- ERB:START partial: inner_partial AND partial_absolute_path: ./fixtures/_inner_partial.erb -->\n"+
    "This is second partial content.\n"+
    "<!-- ERB:END partial: inner_partial AND partial_absolute_path: ./fixtures/_inner_partial.erb -->"
    assert_equal str, @view.render(:partial => "inner_partial")
  end

  def test_with_nil_contents
    assert_nothing_raised { @view.render(:partial => "inner_partial", :collection => []) }
  end

  def test_render_partial_top_with_locals
    ActionView::Partials.partioprint_decorators =  [LocalsPrinter, PartioPrinter]
    str = "<!-- ERB:START partial: top_partial AND partial_absolute_path: ./fixtures/_top_partial.erb -->\n"+
    "<!-- START Local variables:-->\n"+
    "<!-- object : null -->\n"+
    "<!-- top_partial : null -->\n"+
    "<!-- END Local variables:-->\n"+
    "this is top partial\n"+
    "<!-- ERB:START partial: inner_partial AND partial_absolute_path: ./fixtures/_inner_partial.erb -->\n"+
    "<!-- START Local variables:-->\n"+
    "<!-- object : null -->\n"+
    "<!-- inner_partial : null -->\n"+
    "<!-- END Local variables:-->\n"+
    "This is second partial content.\n"+
    "<!-- ERB:END partial: inner_partial AND partial_absolute_path: ./fixtures/_inner_partial.erb -->\n"+
    "<!-- ERB:END partial: top_partial AND partial_absolute_path: ./fixtures/_top_partial.erb -->"
    assert_equal str, @view.render(:partial => "top_partial")
  end

  def test_render_partial_inner_with_locals_printer
    ActionView::Partials.partioprint_decorators =  [LocalsPrinter, PartioPrinter]
    str = "<!-- ERB:START partial: inner_partial AND partial_absolute_path: ./fixtures/_inner_partial.erb -->\n"+
    "<!-- START Local variables:-->\n"+
    "<!-- object : null -->\n"+
    "<!-- inner_partial : null -->\n"+
    "<!-- END Local variables:-->\n"+
    "This is second partial content.\n"+
    "<!-- ERB:END partial: inner_partial AND partial_absolute_path: ./fixtures/_inner_partial.erb -->"
    assert_equal str, @view.render(:partial => "inner_partial")
  end

  def test_render_partial_inner_with_local_printer_diffrent_locals
    ActionView::Partials.partioprint_decorators =  [LocalsPrinter, PartioPrinter]
    str = "<!-- ERB:START partial: inner_partial AND partial_absolute_path: ./fixtures/_inner_partial.erb -->\n"+
    "<!-- START Local variables:-->\n"+
    "<!-- obj : {} -->\n"+
    "<!-- object : null -->\n"+
    "<!-- int : 1 -->\n"+
    "<!-- arr : [1,\"str\"] -->\n"+
    "<!-- inner_partial : null -->\n"+
    "<!-- str : \"str\" -->\n"+
    "<!-- END Local variables:-->\n"+
    "This is second partial content.\n"+
    "<!-- ERB:END partial: inner_partial AND partial_absolute_path: ./fixtures/_inner_partial.erb -->"
    assert_equal str, @view.render(:partial => "inner_partial", :locals => 
    { :obj => Object.new, :str => "str", :int => 1, :arr => [1, "str"] })
  end
  
  def test_with_nil_contents_with_locals_printer
    ActionView::Partials.partioprint_decorators =  [LocalsPrinter, PartioPrinter]
    assert_nothing_raised { @view.render(:partial => "inner_partial", :collection => []) }
  end
  
end


