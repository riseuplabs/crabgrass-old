module AuthenticatedTestHelper
  # Sets the current user in the session from the user fixtures.
  def login_as(user)
    @controller.instance_eval("@current_user = nil")
    @request.session[:user] = user ? users(user).id : nil
  end

  def select_host(host)
    @request.host = host
  end

  def content_type(type)
    @request.env['Content-Type'] = type
  end

  def accept(accept)
    @request.env["HTTP_ACCEPT"] = accept
  end

  def authorize_as(user)
    if user
      @request.env["HTTP_AUTHORIZATION"] = "Basic #{Base64.encode64("#{users(user).login}:test")}"
      accept       'application/xml'
      content_type 'application/xml'
    else
      @request.env["HTTP_AUTHORIZATION"] = nil
      accept       nil
      content_type nil
    end
  end

  # http://project.ioni.st/post/217#post-217
  #
  #  def test_new_publication
  #    assert_difference(Publication, :count) do
  #      post :create, :publication => {...}
  #      # ...
  #    end
  #  end
  #

  def assert_http_authentication_required(login = nil)
    yield XmlLoginProxy.new(self, login)
  end

  def reset!(*instance_vars)
    instance_vars = [:controller, :request, :response] unless instance_vars.any?
    instance_vars.collect! { |v| "@#{v}".to_sym }
    instance_vars.each do |var|
      instance_variable_set(var, instance_variable_get(var).class.new)
    end
  end
end

class BaseLoginProxy
  attr_reader :controller
  attr_reader :options
  def initialize(controller, login, host)
    @controller = controller
    @login      = login
    @host       = host
  end

  private
    def authenticated
      raise NotImplementedError
    end

    def check(method)
      raise NotImplementedError
    end

    def method_missing(method, *args)
      @controller.reset!
      authenticate
      @controller.send(method, *args)
      check(method,*args)
    end
end

class HttpLoginProxy < BaseLoginProxy
  protected
    def authenticate
      @controller.login_as @login if @login
      @controller.select_host @host if @host
    end

    def check(method,*args)
      @controller.assert_redirected_to({:controller => 'account', :action => 'login'}, "%s: %s(%s) did not require a login" % [@controller, method, args.collect{|a|a.inspect}.join(', ')])
    end
end

class XmlLoginProxy < BaseLoginProxy
  protected
    def authenticate
      @controller.accept 'application/xml'
      @controller.authorize_as @login if @login
    end

    def check(method)
      @controller.assert_response 401
    end
end
