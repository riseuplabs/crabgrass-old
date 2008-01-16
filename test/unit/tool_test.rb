require File.dirname(__FILE__) + '/../test_helper'

class ToolTest < Test::Unit::TestCase

  def setup
  end

  def test_tool_namespace
    new = Tool::Message.new :title => 'a message', :public => true
    assert new.save!
    
    find_base = Page.find(new)
    assert_equal find_base.send(:read_attribute, :type), 'Tool::Message'
    assert find_base.is_a?(Tool::Message)

    assert_nothing_raised do
      find = Tool::Message.find(new)
    end
  end

end
