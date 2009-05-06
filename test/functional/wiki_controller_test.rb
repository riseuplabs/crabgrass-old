require File.dirname(__FILE__) + '/../test_helper'
require 'wiki_controller'

# Re-raise errors caught by the controller.
class WikiController; def rescue_action(e) raise e end; end

class WikiControllerTest < Test::Unit::TestCase
  fixtures :groups, :pages, :users, :memberships, :sites
  
  def setup
    @controller = WikiController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

# TODO: write tests for this controller


  def test_show
    assert true
  end

end
