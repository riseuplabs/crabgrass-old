require File.dirname(__FILE__) + '/../test_helper'

class RequestsTest < ActionController::IntegrationTest
  def test_redeem_signup
    req = RequestToJoinUsViaEmail.create(
      :created_by => users(:dolphin),
      :email => 'root@localhost',
      :requestable => groups(:animals),
      :language => languages(:pt)
    )

    mail = Mailer.create_request_to_join_us(req, mailer_options)
    first_url = mail.body.match(/http:\/\/.*/)[0]
    assert_equal "http://localhost:3000/invites/accept/#{req.code}/root_at_localhost", first_url

    get first_url

    redirect_path_encoded = "%2Frequests%2Fredeem%3Fcode%3D#{req.code}%26email%3Droot%2540localhost"
    redirect_path = "/requests/redeem?code=#{req.code}&email=root@localhost"

    login_url = "http://localhost/account/login?redirect=#{redirect_path_encoded}"
    signup_url = "http://localhost/account/signup?redirect=#{redirect_path_encoded}"

    assert_select ".main_column a" do |elements|
      assert_select elements[0], 'a', "I already have an account"
      assert_equal login_url, elements[0]['href']
      assert_select elements[1], 'a', "I need to register a new account"
      assert_equal signup_url, elements[1]['href']
    end

    get signup_url
    assert_response :success

    assert_difference 'User.count' do
      post('/account/signup', {:redirect => redirect_path, :usage_agreement_accepted => "1", :user => {:login => 'stellersjay', :password => 'chirp', :password_confirmation => 'chirp'}})
    end

    assert redirect?
    assert_difference 'Membership.count' do
      follow_redirect!
    end
    assert_equal "/requests/redeem?code=#{req.code}&email=root@localhost", path

    assert redirect?
    follow_redirect!
    assert_equal "/me/dashboard", path
  end

  def test_redeem_login
    req = RequestToJoinUsViaEmail.create(
      :created_by => users(:dolphin),
      :email => 'root@localhost',
      :requestable => groups(:animals),
      :language => languages(:pt)
    )
    redirect_path = "/requests/redeem?code=#{req.code}&email=root@localhost"
    post('/account/login', {:redirect => redirect_path, :login => 'red', :password => 'red'})
    assert redirect?
    assert_difference 'Membership.count' do
      follow_redirect!
    end
    assert redirect?
    follow_redirect!
    assert_equal "/me/dashboard", path
  end

end
