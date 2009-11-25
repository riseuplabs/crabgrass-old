require File.dirname(__FILE__) + '/../test_helper'

class DummyRequest
  attr_accessor :symbolized_path_parameters

  def initialize
    @get = true
    @params = {}
    @symbolized_path_parameters = { :controller => 'foo', :action => 'bar' }
  end

  def get?
    @get
  end

  def post
    @get = false
  end

  def relative_url_root
    ''
  end

  def params(more = nil)
    @params.update(more) if more
    @params
  end
end

class DummyController
  attr_reader :request
  attr_accessor :controller_name

  def initialize
    @request = DummyRequest.new
    @url = ActionController::UrlRewriter.new(@request, @request.params)
  end

  def params
    @request.params
  end

  def url_for(params)
    @url.rewrite(params)
  end
end

class ModalboxTest < Test::Unit::TestCase
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::CaptureHelper

  include ModalboxHelper
  include ModalboxHelper::ActionViewExtension

  def form_authenticity_token
    'token'
  end

  def setup
    @controller = DummyController.new
  end

  def test_link_to_confirm
    ##
    ## what it is normally
    ##

    html = %(<a href="/controller/action/id" onclick="return confirm('are you sure?');">label</a>)
    assert_dom_equal html, link_to_without_confirm('label', {:controller => 'controller', :action => 'action', :id => 'id'}, :confirm => 'are you sure?')

    ##
    ## what it is with modalbox helper
    ##

    html = %(<a href="#" onclick="Modalbox.confirm(&quot;are you sure?&quot;, {method:&quot;post&quot;, action:&quot;/controller/action/id&quot;, token:&quot;token&quot;, title:&quot;label&quot;, ok:&quot;OK&quot;, cancel:&quot;Cancel&quot;}); return false;">label</a>)
    assert_dom_equal html, link_to('label', {:controller => 'controller', :action => 'action', :id => 'id'}, :confirm => 'are you sure?')
  end

end

