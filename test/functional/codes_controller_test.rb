require File.dirname(__FILE__) + '/../test_helper'

class CodesControllerTest < ActionController::TestCase

  def test_xss_prevention
    get :jump, :id => '<body onload="javascript:alert(0);">'
    assert_select 'p', "The code \"&lt;body onload=&quot;javascript:alert(0);&quot;&gt;\" has expired or does not exist."
    assert_response :success
  end
end
