require File.dirname(__FILE__) + '/../test_helper'

class ToolTest < Test::Unit::TestCase

  fixtures :pages, :users

  def setup
    #@page = create_page :title => 'this is a very fine test page'
    # @page_tool_count = @page.tools.length
  end

  def test_wiki
    page = PageType::Wiki.new :title => 'blah'
    page.new_tool
    assert page.save, 'page should save'
    puts page.to_yaml
    puts Page.find(page.id).to_yaml
  end

end
