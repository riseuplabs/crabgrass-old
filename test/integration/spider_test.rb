require "#{File.dirname(__FILE__)}/../test_helper"

class SpiderTest < ActionController::IntegrationTest
  include Caboose::SpiderIntegrator

  fixtures :users, :groups, :pages, :tasks, :profiles

  def test_spider
    get '/'
    assert_response :success
    post '/account/login', :login => 'quentin', :password => 'quentin'
    assert session[:user]
    assert_response :redirect
    assert_redirected_to '/me'
    follow_redirect!

    assert_response :redirect
    assert_redirected_to '/me/dashboard'
    follow_redirect!

    spider(@response.body, '/me/dashboard', :ignore_urls => [/we.riseup.net/])
  end
end
