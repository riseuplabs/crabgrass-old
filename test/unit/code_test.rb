require File.dirname(__FILE__) + '/../test_helper'

class CodeTest < ActiveSupport::TestCase

  def test_create
    assert_difference 'Code.count' do
      Code.create! :expires_at => 1.hour.ago
    end
    assert_difference 'Code.count' do
      Code.create! :expires_at => 1.hour.from_now
    end

    assert_equal 2, Code.find(:all).size

    Code.cleanup_expired

    assert_equal 1, Code.find(:all).size
  end

end


