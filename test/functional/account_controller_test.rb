require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

class AccountControllerTest < ActionController::TestCase
  fixtures :users, :groups, :sites, :tokens

  def teardown
    ActionMailer::Base.deliveries.clear
  end

  def test_should_login_and_redirect
    get :login
    assert_response :success

    post :login, :login => 'quentin', :password => 'quentin'
    assert session[:user]
    assert_response :redirect
    assert_redirected_to :controller => 'me/dashboard'
  end

  def test_should_fail_login_and_not_redirect
    post :login, :login => 'quentin', :password => 'bad password'
    assert_nil session[:user]
    assert_response :success
  end

  def test_should_allow_signup
    assert_difference 'User.count' do
      post_signup_form
      assert_response :redirect
    end
  end

  repeat_with_sites(:local => {:signup_mode => Conf::SIGNUP_MODE[:closed]}) do
    def test_signup_disabled
      assert_no_difference 'User.count' do
        post_signup_form
      end
    end
  end

  repeat_with_sites(:local => {:signup_mode => Conf::SIGNUP_MODE[:invite_only]}) do
    def test_signup_invite
      assert_no_difference 'User.count' do
        post_signup_form
      end
      session[:user_has_accepted_invite] = true
      assert_difference 'User.count' do
        post_signup_form
      end
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference 'User.count' do
      post_signup_form(:user => {:login => nil})
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'User.count' do
      post_signup_form(:user => {:password => nil})
      assert assigns(:user).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'User.count' do
      post_signup_form(:user => {:password_confirmation => nil})
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_not_allow_duplicate_username_or_groupname
    [ users(:quentin).login, groups(:rainbow).name ].each { |login|
      assert_no_difference 'User.count', "number of users should not increase when creating #{login}" do
        post_signup_form(:user => {:login => login,
                    :password => 'passwd',
                    :password_confirmation => 'passwd'})
        assert assigns(:user).errors.on(:login), "flash should yield error for #{login}"
        assert_response :success, "response to creating #{login} should be success"
      end
    }
  end

  repeat_with_sites(:local => {:require_user_email => true}) do
    def test_should_require_email_on_signup
      assert_no_difference 'User.count' do
        post_signup_form(:user => {:email => nil})
        assert assigns(:user).errors.on(:email)
        assert_response :success
      end
    end
  end

  def test_should_logout
    login_as :quentin
    get :logout
    assert_nil session[:user]
    assert_response :redirect
  end

  def test_should_remember_me
    post :login, :login => 'quentin', :password => 'quentin', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    post :login, :login => 'quentin', :password => 'quentin', :remember_me => "0"
    assert_nil @response.cookies["auth_token"]
  end

  def test_should_delete_token_on_logout
    login_as :quentin
    get :logout
    assert_equal @response.cookies["auth_token"], []
  end

=begin
  #not enabled
  def test_should_login_with_cookie
    users(:quentin).remember_me
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :index
    assert @controller.send(:logged_in?)
  end
=end

  def test_should_fail_expired_cookie_login
    users(:quentin).remember_me
    users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :index
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    users(:quentin).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :index
    assert !@controller.send(:logged_in?)
  end

  def test_forgot_password
    get :forgot_password
    assert_response :success

    old_count = Token.count
    post :forgot_password, :email => users(:quentin).email
    assert_response :redirect
    assert_equal old_count + 1, Token.count

    token = Token.find(:last)
    assert_equal "recovery", token.action
    assert_equal users(:quentin).id, token.user_id

    get :reset_password, :token => token.value
    assert_response :success

    post :reset_password, :token => token.value, :new_password => "abcde", :password_confirmation => "abcde"
    assert_response :redirect
    assert_equal old_count, Token.count
  end

  def test_forgot_password_invalid_email_should_stay_put
    post :forgot_password, :email => "not rfc822-compliant"
    assert_response :success
  end

  def test_redirect_on_old_or_invalid_token
    get :reset_password, :token => tokens(:old_token).value
    assert_response :redirect

    get :reset_password, :token => tokens(:strange).value
    assert_response :redirect

    get :reset_password, :token => "invalid"
    assert_response :redirect

    get :reset_password, :token => tokens(:tokens_003).value
    assert_response :success
  end

  repeat_with_sites(:local => {:signup_mode => Conf::SIGNUP_MODE[:default]}) do
    def test_should_not_send_email_verification_when_not_enabled
      assert_no_difference('ActionMailer::Base.deliveries.size') { post_signup_form }
      assert_response :redirect
      assert !assigns(:user).unverified
    end
  end

  repeat_with_sites(:local => {:signup_mode => Conf::SIGNUP_MODE[:verify_email]}) do

    def test_signup_with_verification
      assert_difference('User.count', 1) { post_signup_form }

      user = assigns(:user)
      assert user.unverified
      assert_equal 'quire', user.login
    end

    def test_signup_should_send_verification_email
      assert_difference('ActionMailer::Base.deliveries.size', 1) { post_signup_form }

      # should generate a token
      token = assigns(:token)
      assert_not_nil token
      assert_equal 'verify', token.action

      confirmation_email = ActionMailer::Base.deliveries.last
      #  the email should be for the right person and the right site
      assert_equal confirmation_email.to[0], 'quire@localhost'
      assert_equal I18n.t(:welcome_title, :site_title => Site.current.title),
                    confirmation_email.subject
      # should have the right link
      assert_match %r[http://test.host/verify_email/#{token.value}], confirmation_email.body
    end

    def test_invalid_looking_email_should_fail
      assert_no_difference('ActionMailer::Base.deliveries.size') { post_signup_form(:user => {:email => "BADEMAIL"}) }
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end

    def test_login_without_verification_should_remind_to_verify
      gerrard = users(:gerrard)
      gerrard.update_attribute(:unverified, true)

      post :login, :login => 'gerrard', :password => 'gerrard'
      assert session[:user]
      assert_response :redirect
      assert_redirected_to :controller => 'account', :action => 'unverified'
    end

    def test_verify
      gerrard = users(:gerrard)
      gerrard.update_attribute(:unverified, true)
      token = tokens(:verify_gerrard)

      get :verify_email, :token => token.value

      assert_equal token.id, assigns(:token).id
      assert_response :redirect
      assert_redirected_to '/'
      assert_success_message /Successfully Verified/, /Thanks for signing up/
    end

    def test_unneeded_verification
      gerrard = users(:gerrard)
      token = tokens(:verify_gerrard)

      get :verify_email, :token => token.value

      assert_response :redirect
      assert_redirected_to :controller => 'root', :action => 'index'
      assert_success_message /Already.Verified/
    end

    def test_verify_twice
      gerrard = users(:gerrard)
      gerrard.update_attribute(:unverified, true)
      token = tokens(:verify_gerrard)

      get :verify_email, :token => token.value
      assert_redirected_to '/'
      assert_success_message /Successfully Verified/, /Thanks for signing up/

      get :verify_email, :token => token.value
      assert_redirected_to :controller => 'root', :action => 'index'
      assert_success_message /Already.Verified/
    end
  end

  protected

  def post_signup_form(options = {})
    post(:signup, {
      :user => {
         :login => 'quire',
         :email => 'quire@localhost',
         :password => 'quire',
         :password_confirmation => 'quire'
      }.merge(options.delete(:user) || {}),
      :usage_agreement_accepted => "1"
    }.merge(options))
  end

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end

  def cookie_for(user)
    auth_token users(user).remember_token
  end

end
