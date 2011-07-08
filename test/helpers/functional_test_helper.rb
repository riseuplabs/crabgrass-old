module FunctionalTestHelper
  ##
  # currently, for normal requests, we just redirect to the login page
  # when permission is denied. but this should be improved.
  def assert_permission_denied(failure_message='missing "permission denied" message')
    if @response.content_type == Mime::JS
      assert flash = @response.flash, failure_message
      assert_equal "error", flash[:type], failure_message
      if @controller.logged_in?
        assert_equal "Permission Denied", flash[:title], failure_message
      else
        assert_equal "Login Required", flash[:title], failure_message
      end
    else
      if @response.flash[:type]
        assert_equal 'error', flash[:type], failure_message
        assert_equal 'Sorry. You do not have the ability to perform that action', flash[:title], failure_message
        assert_response :redirect
        assert_redirected_to :controller => :account, :action => :login
      else
        assert_select "div#main-content-full blockquote", "Sorry. You do not have the ability to perform that action.", failure_message
      end
    end
  end

  def assert_login_required(message='missing "login required" message')
    assert_equal 'info', flash[:type], message
    assert_equal 'Login Required', flash[:title], message
    assert_response :redirect
    assert_redirected_to :controller => :account, :action => :login
  end

  def assert_error_message(regexp=nil)
    assert_equal 'error', flash[:type], flash.inspect
    if regexp
      assert flash[:text] =~ regexp, 'error message did not match %s. it was %s.'%[regexp.inspect, flash[:text]]
    end
  end

  def assert_message(regexp=nil)
    assert ['error','info','success'].include?(flash[:type]), 'no flash message (%s)'%flash.inspect
    if regexp
      str = flash[:text].any || flash[:title]
      assert(str =~ regexp, 'error message did not match %s. it was %s.'%[regexp.inspect, str])
    end
  end

  def assert_success_message(title_regexp = nil, text_regexp = nil)
    assert_equal 'success', flash[:type]
    if title_regexp
      assert flash[:title] =~ title_regexp, 'success message title did not match %s. it was %s.'%[title_regexp.inspect, flash[:text]]
    end
    if text_regexp
      assert flash[:text] =~ text_regexp, 'success message text did not match %s. it was %s.'%[text_regexp, flash[:text]]
    end
  end

  def assert_layout(layout)
    assert_equal layout, @response.layout
  end

  def assert_no_select(*args)
    if args.count == 4
      message = args.pop
    elsif args.count == 3
      message = args.pop unless args.first.is_a?(HTML::Node)
    end
    selector = args.first.is_a?(HTML::Node) ? args[1] : args[0]
    message ||= "Selector '#{selector}' was not expected but found."
    assert_raise Test::Unit::AssertionFailedError, message do
      assert_select *args
    end
  end
  ##
  ## ROUTE HELPERS
  ##

  def url_for(options)
    url = ActionController::UrlRewriter.new(@request, nil)
    url.rewrite(options)
  end
end
