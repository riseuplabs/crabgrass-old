require File.expand_path(File.join(File.dirname(__FILE__), '../../../../test/test_helper'))

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end

class CsrfKillerController < ActionController::Base
  verify_token :only => :index, :secret => 'abc'

  def index
    render :inline => "<%= form_tag('/') {} %>"
  end
  
  def unsafe
    render :text => 'pwn'
  end
  
  def rescue_action(e) raise e end
end

class CsrfKillerControllerTest < Test::Unit::TestCase
  def setup
    @controller = CsrfKillerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    class << @request.session
      def session_id() 123 end
    end
    @token = Digest::SHA1.hexdigest("--#{@request.session.session_id}--abc--")
  end

  def test_should_render_form_with_token_tag
    get :index
    assert_select 'form>div>input[name=?][value=?]', '_token', @token
  end

  # Replace this with your real tests.
  def test_should_allow_get
    get :index
    assert_response :success
  end
  
  def test_should_allow_post_without_token_on_unsafe_action
    post :unsafe
    assert_response :success
  end
  
  def test_should_not_allow_post_without_token
    assert_raises(CsrfKiller::InvalidToken) { post :index }
  end
  
  def test_should_not_allow_put_without_token
    assert_raises(CsrfKiller::InvalidToken) { put :index }
  end
  
  def test_should_not_allow_delete_without_token
    assert_raises(CsrfKiller::InvalidToken) { delete :index }
  end
  
  def test_should_not_allow_xhr_post_without_token
    assert_raises(CsrfKiller::InvalidToken) { xhr :post, :index }
  end
  
  def test_should_not_allow_xhr_put_without_token
    assert_raises(CsrfKiller::InvalidToken) { xhr :put, :index }
  end
  
  def test_should_not_allow_xhr_delete_without_token
    assert_raises(CsrfKiller::InvalidToken) { xhr :delete, :index }
  end
  
  def test_should_allow_post_with_token
    post :index, :_token => @token
    assert_response :success
  end
  
  def test_should_allow_put_with_token
    put :index, :_token => @token
    assert_response :success
  end
  
  def test_should_allow_delete_with_token
    delete :index, :_token => @token
    assert_response :success
  end
  
  def test_should_allow_post_with_xml
    post :index, :format => 'xml'
    assert_response :success
  end
  
  def test_should_allow_put_with_xml
    put :index, :format => 'xml'
    assert_response :success
  end
  
  def test_should_allow_delete_with_xml
    delete :index, :format => 'xml'
    assert_response :success
  end
end

# no token is given, assume the cookie store is used
class CsrfCookieMonsterController < ActionController::Base
  verify_token :only => :index

  def index
    render :inline => "<%= form_tag('/') {} %>"
  end
  
  def unsafe
    render :text => 'pwn'
  end
  
  def rescue_action(e) raise e end
end

class FakeSessionDbMan
  def self.generate_digest(data)
    Digest::SHA1.hexdigest("secure#{data}secure")
  end
end

class CsrfCookieMonsterControllerTest < Test::Unit::TestCase
  def setup
    @controller = CsrfCookieMonsterController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    # simulate a cookie session store
    @request.session.instance_variable_set(:@dbman, FakeSessionDbMan)

    CsrfCookieMonsterController.class_eval do
      def self.session_options_for(request, action)
        'abc'
      end
    end
    @token = Digest::SHA1.hexdigest('secure"abc"secure')
  end

  def test_should_render_form_with_token_tag
    get :index
    assert_select 'form>div>input[name=?][value=?]', '_token', @token
  end

  # Replace this with your real tests.
  def test_should_allow_get
    get :index
    assert_response :success
  end
  
  def test_should_allow_post_without_token_on_unsafe_action
    post :unsafe
    assert_response :success
  end
  
  def test_should_not_allow_post_without_token
    assert_raises(CsrfKiller::InvalidToken) { post :index }
  end
  
  def test_should_not_allow_put_without_token
    assert_raises(CsrfKiller::InvalidToken) { put :index }
  end
  
  def test_should_not_allow_delete_without_token
    assert_raises(CsrfKiller::InvalidToken) { delete :index }
  end
  
  def test_should_not_allow_xhr_post_without_token
    assert_raises(CsrfKiller::InvalidToken) { xhr :post, :index }
  end
  
  def test_should_not_allow_xhr_put_without_token
    assert_raises(CsrfKiller::InvalidToken) { xhr :put, :index }
  end
  
  def test_should_not_allow_xhr_delete_without_token
    assert_raises(CsrfKiller::InvalidToken) { xhr :delete, :index }
  end
  
  def test_should_allow_post_with_token
    post :index, :_token => @token
    assert_response :success
  end
  
  def test_should_allow_put_with_token
    put :index, :_token => @token
    assert_response :success
  end
  
  def test_should_allow_delete_with_token
    delete :index, :_token => @token
    assert_response :success
  end
  
  def test_should_allow_post_with_xml
    post :index, :format => 'xml'
    assert_response :success
  end
  
  def test_should_allow_put_with_xml
    put :index, :format => 'xml'
    assert_response :success
  end
  
  def test_should_allow_delete_with_xml
    delete :index, :format => 'xml'
    assert_response :success
  end
end